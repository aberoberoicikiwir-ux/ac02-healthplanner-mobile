const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middlewares/auth');
const { listExercises, listFoods } = require('../controllers/masterDataController');

router.get('/exercises', verifyToken, listExercises);
router.get('/foods', verifyToken, listFoods);

module.exports = router;
