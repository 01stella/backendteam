const express = require('express');
const cors = require('cors');
const http = require('http'); 
const { Server } = require('socket.io');
const multer = require('multer');
const path = require('path');
const mysql = require('mysql2/promise'); 
const adminController = require('./controllers/adminController');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*', 
    methods: ['GET', 'POST', 'PATCH']
  }
});

// Notice: bundleRoutes import was removed from here to prevent conflicts!
const orderRoutes = require('./routes/orderRoutes');
const customerRoutes = require('./routes/customerRoutes');
const bundleRoutes = require('./routes/bundleRoutes'); 
const stationRoutes = require('./routes/stationRoutes');

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
  host: 'lumiora-db', // The exact service name from your docker-compose.yml
  user: 'root',
  password: 'rootpassword',
  database: 'lumiora_db'
});

app.use((req, res, next) => {
  req.db = pool;
  req.io = io;
  next();
});

// --- ADMIN ROUTES ---
app.post('/api/admin/menu', upload.single('image'), adminController.addMenuItem);
app.put('/api/admin/menu/:id', upload.single('image'), adminController.updateMenuItem);
app.delete('/api/admin/menu/:id', adminController.deleteMenuItem);

// --- MAIN ROUTES ---
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

app.use('/api/bundles', bundleRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/station', stationRoutes);

server.listen(port, () => {
  console.log(`🚀 Lumiora Backend is running on port ${port}`)
});