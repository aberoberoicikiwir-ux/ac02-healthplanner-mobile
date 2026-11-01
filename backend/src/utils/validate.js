// Helper validasi sederhana. Tiap fungsi mengembalikan string pesan error,
// atau null kalau input-nya valid.

const GENDERS = ['male', 'female'];
const ACTIVITY_LEVELS = ['sedentary', 'light', 'moderate', 'active', 'very_active'];

// Angka dalam rentang [min, max]. Kalau value tidak dikirim (undefined/null)
// dan required=false, dianggap valid (field opsional).
function checkNumber(name, value, min, max, { required = false, integer = false } = {}) {
  if (value === undefined || value === null) {
    return required ? `${name} wajib diisi.` : null;
  }
  const n = Number(value);
  if (typeof value === 'boolean' || value === '' || !Number.isFinite(n)) {
    return `${name} harus berupa angka.`;
  }
  if (integer && !Number.isInteger(n)) return `${name} harus bilangan bulat.`;
  if (n < min || n > max) return `${name} harus antara ${min} dan ${max}.`;
  return null;
}

function checkEnum(name, value, allowed) {
  if (value === undefined || value === null) return null;
  return allowed.includes(value) ? null : `${name} harus salah satu dari: ${allowed.join(', ')}.`;
}

function checkPastDate(name, value) {
  if (value === undefined || value === null) return null;
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return `${name} harus berformat YYYY-MM-DD.`;
  }
  const d = new Date(value + 'T00:00:00Z');
  if (Number.isNaN(d.getTime()) || d.toISOString().slice(0, 10) !== value) {
    return `${name} bukan tanggal yang valid.`;
  }
  if (d > new Date()) return `${name} tidak boleh di masa depan.`;
  return null;
}

// Ambil error pertama dari daftar hasil pengecekan.
function firstError(...checks) {
  return checks.find((c) => c) || null;
}

function profileErrors(body, { requireWeights }) {
  return firstError(
    checkPastDate('birth_date', body.birth_date),
    checkEnum('gender', body.gender, GENDERS),
    checkEnum('activity_level', body.activity_level, ACTIVITY_LEVELS),
    checkNumber('height_cm', body.height_cm, 50, 260),
    checkNumber('weight_current', body.weight_current, 20, 400, { required: requireWeights }),
    checkNumber('weight_target', body.weight_target, 20, 400, { required: requireWeights }),
    body.allergies !== undefined && body.allergies !== null && typeof body.allergies !== 'string'
      ? 'allergies harus berupa teks.'
      : null,
    typeof body.allergies === 'string' && body.allergies.length > 500
      ? 'allergies maksimal 500 karakter.'
      : null
  );
}

function dailyLogErrors(body) {
  return firstError(
    checkNumber('steps', body.steps, 0, 200000, { integer: true }),
    checkNumber('water_liters', body.water_liters, 0, 20),
    checkNumber('weight_kg', body.weight_kg, 20, 400),
    checkNumber('calories_burned', body.calories_burned, 0, 20000, { integer: true })
  );
}

module.exports = { profileErrors, dailyLogErrors };
