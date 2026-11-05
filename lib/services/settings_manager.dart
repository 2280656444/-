import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static final SettingsManager _i = SettingsManager._();
  factory SettingsManager() => _i;
  SettingsManager._();

  final Map<String, Object> _cache = {};
  bool _init = false;

  Future<void> init() async {
    if (_init) return;
    _init = true;

    final defaults = {
      'weekStartMonday': true,
      'showLunar': true,
      'showTerm': true,
      'showFestival': true,
      'showYi': true,
      'showJi': true,
      'showChong': true,
      'showShen': true,
      'notifyEnabled': true,
    };

    final prefs = await SharedPreferences.getInstance();
    for (final k in defaults.keys) {
      _cache[k] = prefs.containsKey(k) ? prefs.get(k)! : defaults[k]!;
    }
  }

  T get<T>(String k, T fallback) {
    return (_cache[k] as T?) ?? fallback;
  }

  Future<void> set(String k, Object v) async {
    _cache[k] = v;
    final prefs = await SharedPreferences.getInstance();
    if (v is bool) {
      await prefs.setBool(k, v);
    } else if (v is int) {
      await prefs.setInt(k, v);
    } else if (v is String) {
      await prefs.setString(k, v);
    }
  }
}
