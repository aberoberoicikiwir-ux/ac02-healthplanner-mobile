const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

// POST /api/auth/register
const register = asyncHandler(async (req, res) => {
  const { name, email, username, password, role } = req.body;

  if (!name || !email || !username || !password || !role) {
    return res.status(400).json({ message: 'Semua field wajib diisi.' });
  }
  if (!['klien', 'pt'].includes(role)) {
    return res.status(400).json({ message: "role harus 'klien' atau 'pt'." });
  }

  if (typeof password !== 'string' || password.length < 6) {
    return res.status(400).json({ message: 'Password minimal 6 karakter.' });
  }
  if (typeof email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ message: 'Format email tidak valid.' });
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const [result] = await pool.query(
    `INSERT INTO users (name, email, username, password_hash, role)
     VALUES (?, ?, ?, ?, ?)`,
    [name, email, username, passwordHash, role]
  );

  res.status(201).json({
    message: 'Registrasi berhasil.',
    user_id: result.insertId,
  });
});

// POST /api/auth/login
const login = asyncHandler(async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ message: 'Username dan password wajib diisi.' });
  }

  const [rows] = await pool.query(
    `SELECT user_id, name, password_hash, role FROM users WHERE username = ?`,
    [username]
  );

  if (rows.length === 0) {
    return res.status(401).json({ message: 'Username atau password salah.' });
  }

  const user = rows[0];
  const isMatch = await bcrypt.compare(password, user.password_hash);

  if (!isMatch) {
    return res.status(401).json({ message: 'Username atau password salah.' });
  }

  const token = jwt.sign(
    { user_id: user.user_id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  res.json({
    message: 'Login berhasil.',
    token,
    user: { user_id: user.user_id, name: user.name, role: user.role },
  });
});

// POST /api/auth/logout
// JWT bersifat stateless, jadi "logout" cukup dihapus tokennya di sisi
// client (mobile/web). Endpoint ini disediakan untuk konsistensi API.
const logout = asyncHandler(async (req, res) => {
  res.json({ message: 'Logout berhasil.' });
});

module.exports = { register, login, logout };
