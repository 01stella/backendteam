// backend/controllers/bundleController.js
const db = require('../config/db'); // Adjust this path to wherever your MySQL connection pool is exported

exports.getBundles = async (req, res) => {
  try {
    // We use GROUP_CONCAT to merge the multiple included items into a single string, 
    // which we will split into an array before sending to Flutter.
    const query = `
      SELECT 
        b.id, 
        b.name, 
        b.price, 
        b.image_url,
        GROUP_CONCAT(mi.item_name SEPARATOR '||') as included_items
      FROM bundles b
      LEFT JOIN bundle_items bi ON b.id = bi.bundle_id
      LEFT JOIN menu_items mi ON bi.menu_id = mi.id
      GROUP BY b.id
    `;

    const [results] = await db.query(query);

    // Format the data to match exactly what bundle_model.dart expects
    const formattedBundles = results.map(row => {
      return {
        id: row.id,
        name: row.name,
        price: row.price,
        image_url: row.image_url,
        // Convert the "Item1||Item2" string into an array: ["Item1", "Item2"]
        // If there are no items, return an empty array []
        included_items: row.included_items ? row.included_items.split('||') : []
      };
    });

    res.status(200).json({
      success: true,
      data: formattedBundles
    });

  } catch (error) {
    console.error('Error fetching bundles:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load bundles from database'
    });
  }
};