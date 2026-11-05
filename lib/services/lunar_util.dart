import 'package:lunar/lunar.dart';

class LunarUtil {
  /// 农历 → 公历
  static DateTime lunarToSolar({
    required int lunarYear,
    required int lunarMonth,
    required int lunarDay,
    bool isLeap = false,
  }) {
    final m = lunarMonth.clamp(1, 12);
    final d = lunarDay.clamp(1, 30);
    final month = isLeap ? -m : m;
    final lunar = Lunar.fromYmd(lunarYear, month, d);
    final solar = lunar.getSolar();
    return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
  }

  /// 公历 → 农历字符串（示例：正月初八）
  static String solarToLunarLabel(DateTime date) {
    final lunar = Solar.fromYmd(date.year, date.month, date.day).getLunar();
    return '${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
  }

  /// 取最近一次农历生日对应的公历日
  static DateTime nextSolarDate({
    required int month,
    required int day,
    bool isLeap = false,
    DateTime? from,
  }) {
    final base = from ?? DateTime.now();
    for (int offset = 0; offset <= 5; offset++) {
      final tryYear = base.year + offset;
      try {
        final d = lunarToSolar(
          lunarYear: tryYear,
          lunarMonth: month,
          lunarDay: day,
          isLeap: isLeap,
        );
        final today = DateTime(base.year, base.month, base.day);
        if (!d.isBefore(today)) return d;
      } catch (_) {
        // 该年无此闰月，跳过
      }
    }
    return DateTime(base.year, month, day);
  }
}
