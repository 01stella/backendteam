const express = require('express');
const router = express.Router();

// Route to get pending items FOR A SPECIFIC STATION
router.get('/pending/:stationCode', async (req, res) => {
  try {
    const { stationCode } = req.params;
    const query = `
      SELECT 
        oi.id AS order_item_id,
        oi.order_id,
        m.item_name,
        oi.quantity,
        oi.ice_level,
        oi.sugar_level,
        oi.coffee_strength,
        oi.notes,
        oi.item_status
      FROM order_items oi
      JOIN menu m ON oi.menu_id = m.id
      WHERE oi.item_status = 'pending' AND m.station_code = ?
      ORDER BY oi.order_id ASC
    `;
    // We pass stationCode securely into the SQL query here
    const [rows] = await req.db.query(query, [stationCode]);
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Route to mark a specific item as processed
router.patch('/process/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await req.db.query("UPDATE order_items SET item_status = 'processed' WHERE id = ?", [id]);
    
    // NEW: Broadcast to all connected clients that the queue updated
    req.io.emit('queue_updated'); 
    
    res.json({ success: true, message: `Order item ${id} is now processed!` });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;