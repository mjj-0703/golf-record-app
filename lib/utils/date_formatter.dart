const _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

String formatRecordDate(DateTime date) {
  final weekday = _weekdays[date.weekday - 1];
  return '${date.year}年${date.month}月${date.day}日（$weekday）';
}
