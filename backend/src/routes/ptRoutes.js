const express = require('express');
const router = express.Router();
const { verifyToken, requireRole } = require('../middlewares/auth');
const ptController = require('../controllers/ptController');

// Semua route di sini cuma boleh diakses oleh user login dengan role 'pt'
router.use(verifyToken, requireRole('pt'));

router.get('/clients', ptController.getMyClients);
router.get('/clients/:clientId', ptController.getClientDetail);
router.get('/clients/:clientId/progress', ptController.getClientProgress);

router.get('/clients/:clientId/ai-analysis/current', ptController.getCurrentAiAnalysis);
router.patch('/ai-analysis/:analysisId/approve', ptController.approveAiAnalysis);
router.patch('/ai-analysis/:analysisId/override', ptController.overrideAiAnalysis);

module.exports = router;
