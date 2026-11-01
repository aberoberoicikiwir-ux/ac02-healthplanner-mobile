// Bungkus tiap controller async dengan ini, biar error di dalamnya
// otomatis dilempar ke errorHandler middleware, tanpa perlu nulis
// try/catch berulang-ulang di setiap fungsi.
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = asyncHandler;
