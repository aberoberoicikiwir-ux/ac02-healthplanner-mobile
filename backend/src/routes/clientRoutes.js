const express = require('express');
const router = express.Router();
const { verifyToken, requireRole } = require('../middlewares/auth');
const clientController = require('../controllers/clientController');
const workoutController = require('../controllers/workoutController');
const mealController = require('../controllers/mealController');

// Semua route di sini cuma boleh diakses oleh user login dengan role 'klien'
router.use(verifyToken, requireRole('klien'));

router.get('/me/profile', clientController.getMyProfile);
router.post('/me/profile', clientController.createMyProfile);
router.patch('/me/profile', clientController.updateMyProfile);
router.post('/me/pt', clientController.assignMyPt);

router.get('/me/targets/current', clientController.getCurrentTargets);

router.get('/me/daily-logs/today', clientController.getTodayLog);
router.put('/me/daily-logs/today', clientController.upsertTodayLog);
router.get('/me/daily-logs', clientController.getLogsRange);

router.get('/me/workout-plans/current', workoutController.getCurrentWorkoutPlan);
router.get('/me/meal-plans/current', mealController.getCurrentMealPlan);

module.exports = router;
