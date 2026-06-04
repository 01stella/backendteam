// 1. NEW: The Calculate Endpoint (Previews the math without saving)
exports.calculateOrder = async (req, res, next) => {
  try {
    const { items } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'items array is required' });
    }

    let subtotal = 0;
    for (let item of items) {
      const [menuData] = await req.db.query('SELECT price FROM menu WHERE id = ?', [item.menu_id]);
      if (!menuData || menuData.length === 0) throw new Error(`Menu item ${item.menu_id} not found`);
      subtotal += Number(menuData[0].price) * Number(item.quantity);
    }

    // THE SINGLE SOURCE OF TRUTH FOR MATH
    const pb1 = subtotal * 0.10;
    const vat = subtotal * 0.11;
    const grandTotal = subtotal + pb1 + vat;

    res.status(200).json({ 
      success: true, 
      data: {
        subtotal: Math.round(subtotal),
        pb1: Math.round(pb1),
        vat: Math.round(vat),
        total: Math.round(grandTotal)
      }
    });

  } catch (error) {
    console.error("❌ Calculate Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 2. UPDATED: The Checkout Endpoint (Calculates and SAVES the order)
exports.createOrder = async (req, res, next) => {
  try {
    console.log("🚀 Payload Received from Flutter:", JSON.stringify(req.body, null, 2));
    
    // Grabbing the new payment_method from Flutter (fallback to 'cashier' just in case)
    const { customer_id, items, payment_method = 'cashier' } = req.body;

    if (!customer_id || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'customer_id and a non-empty items array are required' });
    }

    // Decide the starting order_status based on their payment choice
    const initialOrderStatus = payment_method === 'app_qr' ? 'pending' : 'processing';

    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');

    let subtotal = 0;
    for (let item of items) {
      const [menuData] = await req.db.query('SELECT price FROM menu WHERE id = ?', [item.menu_id]);
      if (!menuData || menuData.length === 0) throw new Error(`Menu item ${item.menu_id} not found`);
      item.db_price = menuData[0].price;
      subtotal += Number(item.db_price) * Number(item.quantity);
    }

    // APPLY THE EXACT SAME MATH HERE TO CHARGE THE USER CORRECTLY
    const pb1 = subtotal * 0.10;
    const vat = subtotal * 0.11;
    const grandTotal = Math.round(subtotal + pb1 + vat);

    // UPDATED INSERT STATEMENT to include the new columns
    const [orderResult] = await req.db.query(
      `INSERT INTO orders (customer_id, total, order_status, payment_method, payment_status, created_at, modified_at)
       VALUES (?, ?, ?, ?, 'unpaid', ?, ?)`,
      [customer_id, grandTotal, initialOrderStatus, payment_method, now, now]
    );
    const newOrderId = orderResult.insertId; 

   // Inside createOrder's for-loop...
    for (let item of items) {
      await req.db.query(
        `INSERT INTO order_items (order_id, menu_id, quantity, ice_level, sugar_level, coffee_strength, item_price)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          newOrderId, 
          item.menu_id, 
          item.quantity, 
          item.ice_level || 'Normal', 
          item.sugar_level || 'Normal', 
          item.coffee_strength || 'Normal', 
          item.db_price
        ]
      );
    }
    res.status(201).json({ success: true, message: 'Order created', order_id: newOrderId, total: grandTotal });

  } catch (error) {
    console.error("❌ Controller Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 3. NEW: Called by the FLUTTER APP when the customer clicks "I Have Transferred"
exports.markPaymentPending = async (req, res) => {
  try {
    const { id } = req.params;
    await req.db.query(
      `UPDATE orders SET payment_status = 'pending_verification' WHERE id = ?`,
      [id]
    );
    res.json({ success: true, message: 'Payment sent to barista for verification.' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 4. NEW: Called by the BARISTA WEB APP when they verify the funds arrived
exports.verifyPayment = async (req, res) => {
  try {
    const { id } = req.params;
    await req.db.query(
      `UPDATE orders SET payment_status = 'paid', order_status = 'processing' WHERE id = ?`,
      [id]
    );
    res.json({ success: true, message: 'Payment verified! Order sent to kitchen.' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 5. NEW: Called when the customer wants to cancel their payment verification
exports.cancelPaymentVerification = async (req, res) => {
  try {
    const { id } = req.params;
    await req.db.query(
      `UPDATE orders SET payment_status = 'unpaid' WHERE id = ?`,
      [id]
    );
    res.json({ success: true, message: 'Payment verification cancelled.' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Get Order History for a specific customer
exports.getCustomerOrders = async (req, res) => {
  try {
    const { customerId } = req.params;

    // 1. Fetch the main orders
    const [orders] = await req.db.query(
      `SELECT id, total, order_status, created_at 
       FROM orders 
       WHERE customer_id = ? 
       ORDER BY created_at DESC`,
      [customerId]
    );

    // 2. Loop through and attach the specific items for each order
    for (let order of orders) {
      const [items] = await req.db.query(
        `SELECT oi.quantity, m.item_name, m.price 
         FROM order_items oi
         JOIN menu m ON oi.menu_id = m.id
         WHERE oi.order_id = ?`,
        [order.id]
      );
      order.items = items;
    }

    res.status(200).json({ success: true, data: orders });
  } catch (error) {
    console.error("Fetch Orders Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};