const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise'); // Using mysql2/promise for clean async/await

const app = express();
const port = 3000;

// Middleware
app.use(cors()); 
app.use(express.json()); 

// MySQL Connection Pool
// This replaces your PostgreSQL 'Pool' setup
const pool = mysql.createPool({
  host: 'localhost',      // Since it's mapped to port 3306 on your host
  user: 'root',           // Default MySQL root user
  password: 'rootpassword', // Matches your docker-compose.yml
  database: 'lumiora_db',   // Matches your docker-compose.yml
  port: 3306,
  waitForConnections: true,
  connectionLimit: 10
});

// Middleware to inject the db pool into req
app.use((req, res, next) => {
  req.db = pool;
  next();
});

// Routes
const orderController = require('./controllers/orderController');
app.post('/api/orders', orderController.createOrder);

app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});

app.get('/', (req, res) => {
  res.send('🚀 Lumiora Backend is running!');
});