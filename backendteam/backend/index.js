const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const mysql = require('mysql2/promise'); 
const adminController = require('./controllers/adminController');

const app = express();

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, 'public/images')); 
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname.replace(/\s+/g, '-')); 
  }
});

const upload = multer({ storage: storage });
const port = 3000;

app.use(cors()); 
app.use(express.json()); 

app.use('/images', express.static(path.join(__dirname, 'public/images')));

const pool = mysql.createPool({
  host: 'lumiora-db', // <-- Use the exact service name from your docker-compose.yml
  user: 'root',
  password: 'rootpassword',
  database: 'lumiora_db'
});

app.use((req, res, next) => {
  req.db = pool;
  next();
});

app.post('/api/admin/menu', upload.single('image'), adminController.addMenuItem);
app.put('/api/admin/menu/:id', upload.single('image'), adminController.updateMenuItem);
app.delete('/api/admin/menu/:id', adminController.deleteMenuItem);

app.get('/', (req, res) => {
  res.send('🚀 Lumiora Backend is running!');
});

app.get('/api/menu', async (req, res) => {
  try {
    const query = `
      SELECT m.id as menu_id, m.item_name, m.description, m.price, m.image_url, c.name as category_name
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