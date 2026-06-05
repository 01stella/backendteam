exports.addMenuItem = async (req, res) => {
  try {
    const { category_id, item_name, description, price } = req.body;

    // 1. Validate required fields
    if (!category_id || !item_name || !description || !price) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // 2. Handle the Image Upload (if one was provided)
    const imageUrl = req.file ? `/images/${req.file.filename}` : null;

    // 3. Insert into the database
    const [result] = await req.db.query(
      `INSERT INTO menu (category_id, item_name, description, price, image_url) VALUES (?, ?, ?, ?, ?)`,
      [category_id, item_name, description, price, imageUrl]
    );

    res.status(201).json({ 
        success: true, 
        message: 'Menu item added successfully!',
        id: result.insertId 
    });

  } catch (error) {
    console.error("❌ Admin Add Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateMenuItem = async (req, res) => {
  try {
    const { id } = req.params;
    const { category_id, item_name, description, price } = req.body;

    // 1. Validate required text fields
    if (!category_id || !item_name || !description || !price) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // 2. Prepare the dynamic SQL query
    let sql = `UPDATE menu SET category_id = ?, item_name = ?, description = ?, price = ?`;
    let queryParams = [category_id, item_name, description, price];

    // 3. If the manager uploaded a new picture, add it to the update query!
    if (req.file) {
      const newImageUrl = `/images/${req.file.filename}`;
      sql += `, image_url = ?`;
      queryParams.push(newImageUrl);
    }

    // 4. Target the specific item ID
    sql += ` WHERE id = ?`;
    queryParams.push(id);

    // 5. Execute the update
    const [result] = await req.db.query(sql, queryParams);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Menu item not found' });
    }

    res.json({ success: true, message: 'Menu item updated successfully!' });

  } catch (error) {
    console.error("❌ Admin Update Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.deleteMenuItem = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await req.db.query(`DELETE FROM menu WHERE id = ?`, [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Menu item not found' });
    }

    res.json({ success: true, message: 'Menu item deleted successfully!' });

  } catch (error) {
    console.error("❌ Admin Delete Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};