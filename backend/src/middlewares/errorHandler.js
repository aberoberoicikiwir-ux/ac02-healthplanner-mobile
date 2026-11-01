// Middleware terakhir yang nangkep semua error yang dilempar dari
// controller manapun (lewat asyncHandler), biar responsenya konsisten
// dan nggak nge-crash servernya.
function errorHandler(err, req, res, next) {
  console.error(err);

  // Duplicate entry (constraint UNIQUE dilanggar), misal email sudah dipakai
  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ message: 'Data sudah ada (duplikat).' });
  }

  // Error 5xx bisa berisi detail internal (mis. isi query SQL / struktur tabel),
  // jadi ke klien cukup dikirim pesan umum. Detail lengkap tetap tercatat di console.
  const status = err.status || 500;
  res.status(status).json({
    message: status >= 500 ? 'Terjadi kesalahan pada server.' : err.message,
  });
}

module.exports = errorHandler;
