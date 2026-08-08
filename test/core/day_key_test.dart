import 'package:ascend/core/utils/day_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DayKey', () {
    test('formats local date as YYYY-MM-DD', () {
      expect(DayKey.dayKey(DateTime(2026, 8, 8)), '2026-08-08');
      expect(DayKey.dayKey(DateTime(2026, 12, 31)), '2026-12-31');
      expect(DayKey.dayKey(DateTime(2027, 1, 1)), '2027-01-01');
    });

    test('uses the input date fields, regardless of zone flags', () {
      final local = DateTime(2026, 8, 8, 1, 30);
      final utc = DateTime.utc(2026, 8, 8, 1, 30);
      expect(DayKey.dayKey(local), '2026-08-08');
      expect(DayKey.dayKey(utc), '2026-08-08');
    });

    test('yesterday wraps the month boundary', () {
      final now = DateTime(2026, 3, 1, 12);
      expect(DayKey.yesterday(now), '2026-02-28');
    });

    test('daysAgo supports arbitrary offsets', () {
      final now = DateTime(2026, 8, 8, 9);
      expect(DayKey.daysAgo(now, 3), '2026-08-05');
      expect(DayKey.daysAgo(now, 0), '2026-08-08');
    });
  });
}