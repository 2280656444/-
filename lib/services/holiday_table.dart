import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// 法定节假日 / 调休补班表
/// 数据格式：{ "year": 2026, "days": { "2026-01-01": {"type":"holiday","name":"元旦"}, "2026-02-14": {"type":"workday","name":"春节调休"} } }
class HolidayTable {
  final Map<String, String> _holiday = {}; // 放假
  final Map<String, String> _work = {};    // 补班

  HolidayTable._(this._holiday, this._work);

  factory HolidayTable.empty() => HolidayTable._({}, {});

  static Future<HolidayTable> load() async {
    final allH = <String, String>{};
    final allW = <String, String>{};
    // 内置最近两年，文件缺失时跳过
    for (final y in [DateTime.now().year, DateTime.now().year + 1]) {
      try {
        final s = await rootBundle.loadString('assets/data/holidays_$y.json');
        final j = jsonDecode(s);
        final days = j['days'] as Map<String, dynamic>? ?? {};
        days.forEach((k, v) {
          final type = v['type'] as String?;
          final name = v['name'] as String? ?? '';
          if (type == 'holiday') {
            allH[k] = name;
          } else if (type == 'workday') {
            allW[k] = name;
          }
        });
      } catch (_) {
        // 该年份没有内置文件
      }
    }
    // 云端最新数据优先覆盖（HolidayUpdateService 下载后写入 cache）
    try {
      final s = await rootBundle.loadString('assets/data/holidays_cache.json');
      final j = jsonDecode(s);
      final days = j['days'] as Map<String, dynamic>? ?? {};
      days.forEach((k, v) {
        final type = v['type'] as String?;
        final name = v['name'] as String? ?? '';
        if (type == 'holiday') {
          allH[k] = name;
        } else if (type == 'workday') {
          allW[k] = name;
        }
      });
    } catch (_) {}
    return HolidayTable._(allH, allW);
  }

  bool isHoliday(String key) => _holiday.containsKey(key);
  bool isWorkday(String key) => _work.containsKey(key);

  /// 是否休息日：法定假 或（非补班的周末）
  bool isRestDay(String key, DateTime date) {
    if (_work.containsKey(key)) return false;
    if (_holiday.containsKey(key)) return true;
    final w = date.weekday;
    return w == 6 || w == 7;
  }

  String? nameOf(String key) => _holiday[key] ?? _work[key];
}
