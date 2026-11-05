import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/culture_info.dart';

class CultureService {
  static List<CultureInfo>? _cache;

  static Future<List<CultureInfo>> all() async {
    if (_cache != null) return _cache!;
    final t =
        jsonDecode(await rootBundle.loadString('assets/data/solar_terms.json'));
    final f =
        jsonDecode(await rootBundle.loadString('assets/data/festivals.json'));
    _cache = [...t, ...f].map((e) => CultureInfo.fromJson(e)).toList();
    return _cache!;
  }

  static void clearCache() => _cache = null;

  static Future<CultureInfo?> findByKey(String key) async {
    final list = await all();
    try {
      return list.firstWhere((e) => e.key == key);
    } catch (_) {
      return null;
    }
  }
}
