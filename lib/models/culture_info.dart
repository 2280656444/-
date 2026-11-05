class CultureInfo {
  final String key;
  final String name;
  final String type;
  final String summary;
  final String origin;
  final String custom;
  final String poem;

  CultureInfo({
    required this.key,
    required this.name,
    required this.type,
    required this.summary,
    required this.origin,
    required this.custom,
    this.poem = '',
  });

  factory CultureInfo.fromJson(Map<String, dynamic> j) => CultureInfo(
        key: j['key'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        summary: j['summary'] as String? ?? '',
        origin: j['origin'] as String? ?? '',
        custom: j['custom'] as String? ?? '',
        poem: j['poem'] as String? ?? '',
      );
}
