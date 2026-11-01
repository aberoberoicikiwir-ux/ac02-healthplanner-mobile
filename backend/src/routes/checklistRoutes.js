const express = require('express');
const router = express.Router();
const { verifyToken, requireRole } = require('../middlewares/auth');
const workoutController = require('../controllers/workoutController');
const mealController = require('../controllers/mealController');

router.patch(
  '/workout-plan-items/:itemId',
  verifyToken,
  requireRole('klien'),
  workoutController.updateWorkoutItem
);

router.patch(
  '/meal-plan-items/:itemId',
  verifyToken,
  requireRole('klien'),
  mealController.updateMealItem
);

module.exports = router;
