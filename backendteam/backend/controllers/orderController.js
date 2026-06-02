exports.createOrder = async (req, res, next) => {
  try {
    console.log("🚀 Payload Received from Flutter:", JSON.stringify(req.body, null, 2));

    const { customer_id, items } = req.body;

    if (!customer_id || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'customer_id and a non-empty items array are required' });
    }

    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');

    // 1. Calculate Grand Total AND Validate Items first
    let grandTotal = 0;
    for (let item of items) {
      const [menuData] = await req.db.query('SELECT price FROM menu WHERE id = ?', [item.menu_id]);
      if (!menuData || menuData.length === 0) throw new Error(`Menu item ${item.menu_id} not found`);
      item.db_price = menuData[0].price;
      grandTotal += Number(item.db_price) * Number(item.quantity);
    }

    // 2. Create Parent Order FIRST so we get the newOrderId
    const [orderResult] = await req.db.query(
      `INSERT INTO orders (customer_id, total, order_status, created_at, modified_at)
       VALUES (?, ?, 'pending', ?, ?)`,
      [customer_id, grandTotal, now, now]
    );
    const newOrderId = orderResult.insertId; // This is the ID you were missing!

    // 3. Now loop and insert items using the valid newOrderId
    for (let item of items) {
      await req.db.query(
        `INSERT INTO order_items (order_id, menu_id, quantity, ice_level, sugar_level, item_price)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          newOrderId, 
          item.menu_id, 
          item.quantity, 
          item.ice_level || 'iced',
          item.sugar_level || 'normal',
          item.db_price
        ]
      );
    }

    res.status(201).json({ 
      success: true, 
      message: 'Order created successfully', 
      order_id: newOrderId, 
      total: grandTotal 
    });

  } catch (error) {
    console.error("❌ Controller Error:", error);
    next(error);
  }
};