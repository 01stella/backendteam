const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise'); 

const app = express();
const port = 3000;

// Middleware
app.use(cors()); 
app.use(express.json()); 

// MySQL Connection Pool
const pool = mysql.createPool({
  host: 'localhost',      
  user: 'root',           
  password: 'rootpassword', // Matches your docker-compose
  database: 'lumiora_db',   // Matches your docker-compose
  port: 3306,               // Use 3307 here if we changed it earlier to fix the port conflict!
  waitForConnections: true,
  connectionLimit: 10
});

// Middleware to inject the db pool into req
app.use((req, res, next) => {
  req.db = pool;
  next();
});


// ==========================================
//                 ROUTES
// ==========================================

// 1. Root Test Route
app.get('/', (req, res) => {
  res.send('🚀 Lumiora Backend is running!');
});

// 2. GET MENU ROUTE (This is what was missing!)
app.get('/api/menu', async (req, res) => {
  try {
    // JOIN the menu and category tables so Flutter gets the category names
    const query = `
      SELECT m.id as menu_id, m.item_name, m.description, m.price, c.name as category_name
      FROM menu m
      JOIN category c ON m.category_id = c.id
    `;
    const [rows] = await req.db.query(query);
    
    res.json({ success: true, data: rows });
  } catch (error) {
    console.error("Database error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// 3. CREATE ORDER ROUTE
const orderController = require('./controllers/orderController');
app.post('/api/orders', orderController.createOrder);


// ==========================================
//               START SERVER
// ==========================================
app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});