exports.getBundles = async (req, res) => {
  try {
    const query = `
      SELECT 
        b.id AS bundle_id,
        b.name AS bundle_name,
        b.price,
        b.image_url,
        m.id AS menu_id,
        m.item_name
      FROM bundles b
      LEFT JOIN bundle_items bi ON b.id = bi.bundle_id
      LEFT JOIN menu m ON bi.menu_item_id = m.id
      ORDER BY b.id, bi.id
    `;

    const [rows] = await req.db.query(query);

    const bundleMap = new Map();

    for (const row of rows) {
      if (!bundleMap.has(row.bundle_id)) {
        bundleMap.set(row.bundle_id, {
          id: row.bundle_id,
          name: row.bundle_name,
          price: row.price,
          image_url: row.image_url || '',
          included_items: []
        });
      }

      if (row.menu_id) {
        bundleMap.get(row.bundle_id).included_items.push({
          menu_id: row.menu_id,
          name: row.item_name
        });
      }
    }

    res.status(200).json({
      success: true,
      data: Array.from(bundleMap.values())
    });
  } catch (error) {
    console.error('Error fetching bundles:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to load bundles from database'
    });
  }
};