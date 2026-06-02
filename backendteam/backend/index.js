const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = 3000;

// Middleware
app.use(cors()); // Crucial for Flutter Web testing
app.use(express.json()); // Parses incoming JSON requests

// Database Connection
// Replace these with your actual PostgreSQL credentials
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'lumiora_db',
  password: 'your_password',
  port: 5432,
});

// Pass the database connection to the routes
app.use((req, res, next) => {
  req.db = pool;
  next();
});

// --- Routes ---
const orderController = require('./controllers/orderController');

// Test Route
app.get('/api/test', (req, res) => {
  res.json({ message: 'Backend is live!' });
});

// Order Route
app.post('/api/orders', orderController.createOrder);

// Start Server
app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});