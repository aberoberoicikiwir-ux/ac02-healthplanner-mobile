'use strict';

const express = require('express');
const { requireInternalKey } = require('../middlewares/internalAuth');
const aiController = require('../controllers/aiController');

const router = express.Router();

// Semua route di sini butuh X-Internal-Key, BUKAN JWT pengguna.
router.use(requireInternalKey);
router.post('/ai/generate-weekly-plan', aiController.generate);

module.exports = router;
