const jwt = require('jsonwebtoken');

// Cek header "Authorization: Bearer <token>", verifikasi JWT-nya,
// lalu simpan payload-nya (user_id, role) ke req.user biar bisa
// dipakai controller berikutnya.
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Token tidak ditemukan. Silakan login.' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload; // { user_id, role }
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Token tidak valid atau sudah kedaluwarsa.' });
  }
}

// Contoh pakai: requireRole('pt') atau requireRole('klien', 'pt')
function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Kamu tidak punya akses ke resource ini.' });
    }
    next();
  };
}

module.exports = { verifyToken, requireRole };
