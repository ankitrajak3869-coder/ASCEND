/// Utils: local-time day keys used by streaks, missions and rollups.
///
/// Rule (ADR-05): all backend timestamps are UTC; the *day* boundary is the
/// user's local midnight. A day key is the wall-clock YYYY-MM-DD in the
/// user's timezone — never the UTC date.
abstract final class DayKey {
  static const String _pad = '0';

  static String dayKey(DateTime local) {
    final y = local.year.toString().padLeft(4, _pad);
    final m = local.month.toString().padLeft(2, _pad);
    final d = local.day.toString().padLeft(2, _pad);
    return '$y-$m-$d';
  }

  static String today([DateTime? now]) => dayKey(now ?? DateTime.now());

  /// Key of yesterday relative to [now].
  static String yesterday(DateTime now) =>
      dayKey(DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)));

  /// Day key N days before [now].
  static String daysAgo(DateTime now, int days) =>
      dayKey(DateTime(now.year, now.month, now.day).subtract(Duration(days: days)));
}