'use strict';

const crypto = require('crypto');

// Endpoint "internal" (mis. memicu AI) TIDAK boleh dipanggil dari Mobile/Web.
// Pemanggilnya adalah proses backend sendiri (scheduler/cron) atau developer,
// yang membawa kunci rahasia di header X-Internal-Key.
function requireInternalKey(req, res, next) {
  const expected = process.env.INTERNAL_API_KEY;
  // Kunci kosong atau terlalu pendek = endpoint dimatikan, bukan terbuka.
  if (!expected || expected.length < 16) {
    return res.status(503).json({ message: 'Endpoint internal belum dikonfigurasi (INTERNAL_API_KEY di .env, minimal 16 karakter).' });
  }
  const given = req.get('x-internal-key') || '';
  // Hash dulu agar panjang sama, lalu bandingkan dengan timingSafeEqual (anti timing attack).
  const a = crypto.createHash('sha256').update(given).digest();
  const b = crypto.createHash('sha256').update(expected).digest();
  if (!crypto.timingSafeEqual(a, b)) {
    return res.status(401).json({ message: 'Kunci internal salah atau tidak ada.' });
  }
  next();
}

module.exports = { requireInternalKey };
