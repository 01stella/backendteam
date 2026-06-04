const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

// Route to calculate order totals (Preview)
// Endpoint will be: POST /api/orders/calculate
router.post('/calculate', orderController.calculateOrder);

// Route to officially create the order in the database
// Endpoint will be: POST /api/orders/
router.post('/', orderController.createOrder);

module.exports = router;