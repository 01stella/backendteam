const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

router.get('/', orderController.getAllOrders);

// Route to calculate order totals (Preview)
router.post('/calculate', orderController.calculateOrder);

// Route to officially create the order in the database
router.post('/', orderController.createOrder);

// 1. Customer clicks "I Have Transferred" (Flutter App)
router.put('/:id/claim-paid', orderController.markPaymentPending);

// 2. Barista clicks "Approve" (Barista Web App)
router.put('/:id/verify-payment', orderController.verifyPayment);

// 3. Customer cancels payment verification
router.put('/:id/cancel-payment', orderController.cancelPaymentVerification);

router.get('/customer/:customerId', orderController.getCustomerOrders);
module.exports = router;