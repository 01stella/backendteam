// backend/routes/bundleRoutes.js
const express = require('express');
const router = express.Router();
const bundleController = require('../controllers/bundleController');

// GET /api/bundles
router.get('/', bundleController.getBundles);

module.exports = router;