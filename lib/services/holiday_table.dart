import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// 法定节假日 / 调休补班表
/// 数据格式：{ "year": 2026, "days": { "2026-01-01": {"type":"holiday","name":"元旦"}, "2026-02-14": {"type":"workday","name":"春节调休"} } }
class HolidayTable {
  final Map<String, String> _holiday; // 放假
  final Map<String, String> _work;    // 补班

  // 注意：_holiday / _work 没有默认值，才能在构造参数里用 this._holiday 赋值
  HolidayTable._(this._holiday, this._work);

  factory HolidayTable.empty() => HolidayTable._({}, {});

  static Future<HolidayTable> load() async {
    final allH = <String, String>{};
    final allW = <String, String>{};
    // 内置最近两年，文件缺失时跳过
    for (final y in [DateTime.now().year, DateTime.now().year + 1]) {
      try {
        final s = await rootBundle.loadString('assets/data/holidays_$y.json');
        _merge(s, allH, allW);
      } catch (_) {
        // 该年份没有内置文件
      }
    }
    // 云端最新数据优先覆盖（HolidayUpdateService 下载后写入 cache）
    try {
      final s = await rootBundle.loadString('assets/data/holidays_cache.json');
      _merge(s, allH, allW);
    } catch (_) {}

    return HolidayTable._(allH, allW);
  }

  static void _merge(String s, Map<String, String> allH, Map<String, String> allW) {
    final decoded = jsonDecode(s);
    if (decoded is! Map) return;
    final days = decoded['days'];
    if (days is! Map) return;
    days.forEach((k, v) {
      if (v is! Map) return;
      final type = v['type']?.toString();
      final name = v['name']?.toString() ?? '';
      if (type == 'holiday') {
        allH[k.toString()] = name;
      } else if (type == 'workday') {
        allW[k.toString()] = name;
      }
    });
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
