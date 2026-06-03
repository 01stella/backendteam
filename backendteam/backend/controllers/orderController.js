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
    const { customer_id, items } = req.body;

    if (!customer_id || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'customer_id and a non-empty items array are required' });
    }

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

    const [orderResult] = await req.db.query(
      `INSERT INTO orders (customer_id, total, order_status, created_at, modified_at)
       VALUES (?, ?, 'pending', ?, ?)`,
      [customer_id, grandTotal, now, now]
    );
    const newOrderId = orderResult.insertId; 

    for (let item of items) {
      await req.db.query(
        `INSERT INTO order_items (order_id, menu_id, quantity, ice_level, sugar_level, item_price)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [newOrderId, item.menu_id, item.quantity, item.ice_level || 'iced', item.sugar_level || 'normal', item.db_price]
      );
    }

    res.status(201).json({ success: true, message: 'Order created', order_id: newOrderId, total: grandTotal });

  } catch (error) {
    console.error("❌ Controller Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};