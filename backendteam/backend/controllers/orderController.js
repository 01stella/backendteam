exports.createOrder = async (req, res, next) => {
  try {
    // The Flutter app will now send an array called 'items'
    const { customer_id, items } = req.body;

    if (!customer_id || !items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'customer_id and items array are required' });
    }

    let grandTotal = 0;
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');

    // 1. Calculate the grand total securely using prices straight from the database
    for (let item of items) {
      const [menuData] = await req.db.query('SELECT price FROM menu WHERE id = ?', [item.menu_id]);
      if (menuData.length === 0) {
        return res.status(404).json({ success: false, message: `Menu item ${item.menu_id} not found` });
      }
      item.db_price = menuData[0].price; // Temporarily save it to insert later
      grandTotal += item.db_price * item.quantity;
    }

    // 2. Create the Parent Order
    const [orderResult] = await req.db.query(
      `INSERT INTO orders (customer_id, total, order_status, created_at, modified_at)
       VALUES (?, ?, 'pending', ?, ?)`,
      [customer_id, grandTotal, now, now]
    );
    const newOrderId = orderResult.insertId;

    // 3. Loop through and create the Child Order Items
    for (let item of items) {
      await req.db.query(
        `INSERT INTO order_items (order_id, menu_id, quantity, ice_level, sugar_level, item_price)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [newOrderId, item.menu_id, item.quantity, item.ice_level || 'normal', item.sugar_level || 'normal', item.db_price]
      );
    }

    res.status(201).json({ 
      success: true, 
      message: 'Order created successfully with items', 
      order_id: newOrderId, 
      total: grandTotal 
    });

  } catch (error) {
    next(error);
  }
};