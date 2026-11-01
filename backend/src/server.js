require('dotenv').config();
const express = require('express');
const cors = require('cors');

const errorHandler = require('./middlewares/errorHandler');

const authRoutes = require('./routes/authRoutes');
const clientRoutes = require('./routes/clientRoutes');
const checklistRoutes = require('./routes/checklistRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const ptRoutes = require('./routes/ptRoutes');
const masterDataRoutes = require('./routes/masterDataRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Health check — buat mastiin server hidup, gampang dites pas deploy
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'HealthMaxxing API is running.' });
});

app.use('/api/auth', authRoutes);
app.use('/api/clients', clientRoutes);
app.use('/api', checklistRoutes); // /api/workout-plan-items/:id, /api/meal-plan-items/:id
app.use('/api', notificationRoutes); // /api/users/me/notifications, /api/notifications/:id/read
app.use('/api/pt', ptRoutes);
app.use('/api', masterDataRoutes); // /api/exercises, /api/foods

// 404 handler — kalau path-nya nggak kecocok sama route manapun di atas
app.use((req, res) => {
  res.status(404).json({ message: 'Endpoint tidak ditemukan.' });
});

app.use(errorHandler);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`HealthMaxxing backend jalan di http://localhost:${PORT}`);
});
