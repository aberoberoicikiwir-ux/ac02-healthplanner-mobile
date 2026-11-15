const dayLabels = <String, String>{
  'mon': 'Senin',
  'tue': 'Selasa',
  'wed': 'Rabu',
  'thu': 'Kamis',
  'fri': 'Jumat',
  'sat': 'Sabtu',
  'sun': 'Minggu',
};

const dayOrder = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

String dayLabel(String? code) {
  if (code == null) return 'Tanpa hari';
  return dayLabels[code] ?? code;
}

String mealTypeLabel(String type) {
  switch (type) {
    case 'breakfast':
      return 'Sarapan';
    case 'lunch':
      return 'Makan Siang';
    case 'dinner':
      return 'Makan Malam';
    case 'snack':
      return 'Snack';
    default:
      return type;
  }
}

String categoryLabel(String? category) {
  switch (category) {
    case 'strength':
      return 'Kekuatan';
    case 'cardio':
      return 'Kardio';
    case 'flexibility':
      return 'Kelenturan';
    case null:
      return '-';
    default:
      return category;
  }
}

/// Cardio/flexibility: reps berarti durasi menit. Strength: jumlah repetisi.
String workoutDetail({int? sets, int? reps, String? category}) {
  final r = reps ?? 0;
  if (category == 'cardio' || category == 'flexibility') {
    return '$r menit';
  }
  return '${sets ?? 1} sets x $r reps';
}

String twoDigits(int value) => value.toString().padLeft(2, '0');

/// Tanggal lokal "YYYY-MM-DD" (dipakai sebagai kunci cache log harian).
String localDateString(DateTime date) {
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

String shortDate(String isoDate) {
  if (isoDate.length < 10) return isoDate;
  return '${isoDate.substring(8, 10)}/${isoDate.substring(5, 7)}';
}
