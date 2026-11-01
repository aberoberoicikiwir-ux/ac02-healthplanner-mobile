const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middlewares/auth');
const { getMyNotifications, markNotificationRead } = require('../controllers/notificationController');

router.get('/users/me/notifications', verifyToken, getMyNotifications);
router.patch('/notifications/:id/read', verifyToken, markNotificationRead);

module.exports = router;
