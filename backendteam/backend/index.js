const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise'); 

const app = express();
const port = 3000;

app.use(cors()); 
app.use(express.json()); 

const pool = mysql.createPool({
  host: 'localhost',      
  user: 'root',           
  password: 'rootpassword', 
  database: 'lumiora_db',  
  port: 3306,               
  waitForConnections: true,
  connectionLimit: 10
});

app.use((req, res, next) => {
  req.db = pool;
  next();
});


app.get('/', (req, res) => {
  res.send('🚀 Lumiora Backend is running!');
});

app.get('/api/menu', async (req, res) => {
  try {
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

const orderRoutes = require('./routes/orderRoutes');
app.use('/api/orders', orderRoutes);

const customerRoutes = require('./routes/customerRoutes');
app.use('/api/customers', customerRoutes);


app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});