import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/history_item.dart';

class HistoryService {
  static const _base = 'https://zh.wikipedia.org/api/rest_v1/feed/onthisday';
  static final Map<String, List<HistoryItem>> _mem = {};
  static DateTime? _lastClear;

  static Future<List<HistoryItem>> of(DateTime date) async {
    // 跨天自动清缓存
    final now = DateTime.now();
    if (_lastClear == null || _lastClear!.day != now.day || _lastClear!.month != now.month) {
      _mem.clear();
      _lastClear = now;
    }

    final key = '${date.month}-${date.day}';
    if (_mem.containsKey(key)) return _mem[key]!;

    final list = <HistoryItem>[];
    final ok = await _fetchCloud(date, list);

    if (!ok || list.isEmpty) {
      list.clear();
      list.addAll(await _builtin(date));
    }

    final seen = <String>{};
    final dedup = <HistoryItem>[];
    for (final it in list) {
      if (seen.add('${it.year}_${it.title}')) dedup.add(it);
    }
    dedup.sort((a, b) => b.year.compareTo(a.year));

    _mem[key] = dedup;
    return dedup;
  }

  /// 历史上的今天（默认今天）
  static Future<List<HistoryItem>> today() async {
    final n = DateTime.now();
    return of(DateTime(n.year, n.month, n.day));
  }

  static Future<bool> _fetchCloud(DateTime date, List<HistoryItem> out) async {
    try {
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');

      final resp = await http
          .get(Uri.parse('$_base/all/$m/$d'),
              headers: {'User-Agent': 'Rili/1.0 (suishiji app)'})
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        _parse(j, 'events', '大事件', date, out);
        _parse(j, 'births', '出生', date, out);
        _parse(j, 'deaths', '逝世', date, out);
        return out.isNotEmpty;
      }

      // 兜底：分类型请求
      const types = {'events': '大事件', 'births': '出生', 'deaths': '逝世'};
      for (final t in types.entries) {
        final r = await http
            .get(Uri.parse('$_base/${t.key}/$m/$d'),
                headers: {'User-Agent': 'Rili/1.0 (suishiji app)'})
            .timeout(const Duration(seconds: 8));
        if (r.statusCode == 200) {
          final j = jsonDecode(r.body) as Map<String, dynamic>;
          _parse(j, t.key, t.value, date, out);
        }
      }
      return out.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static void _parse(Map<String, dynamic> j, String key, String category,
      DateTime date, List<HistoryItem> out) {
    final items = j[key] as List<dynamic>? ?? [];
    for (final e in items) {
      if (e is Map<String, dynamic>) {
        out.add(HistoryItem.fromWiki(e, category, date.month, date.day));
      }
    }
  }

  static Future<List<HistoryItem>> _builtin(DateTime date) async {
    try {
      final str = await rootBundle.loadString(
          'assets/data/history/history_${date.month}_${date.day}.json');
      final arr = jsonDecode(str) as List<dynamic>;
      return arr
          .whereType<Map<String, dynamic>>()
          .map((e) => HistoryItem.builtin(e, date.month, date.day))
          .toList();
    } catch (_) {
      // 无本地兜底文件：返回空，由 UI 提示走在线
      return const [];
    }
  }

  static Future<void> prefetch(DateTime date) => of(date);
  static void clearCache() => _mem.clear();
}
