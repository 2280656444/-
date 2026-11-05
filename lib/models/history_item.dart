class HistoryItem {
  final int year;
  final int month;
  final int day;
  final String title;
  final String category;
  final String? link;

  const HistoryItem({
    required this.year,
    required this.month,
    required this.day,
    required this.title,
    this.category = '大事件',
    this.link,
  });

  String get dateLabel => '$year年$month月$day日';
  String get summary => '$year　$title';
  String get mdLabel => '$month月$day日';

  /// 维基 REST API /all 格式：year + text + pages[].content_urls.desktop.page
  factory HistoryItem.fromWiki(
    Map<String, dynamic> e,
    String category,
    int month,
    int day,
  ) {
    final year = e['year'] is int ? e['year'] as int : 0;
    var text = (e['text'] as String? ?? '').replaceAll(RegExp(r'<[^>]+>'), '');
    text = text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    String? url;
    final pages = e['pages'] as List<dynamic>?;
    if (pages != null && pages.isNotEmpty && pages.first is Map<String, dynamic>) {
      final content = (pages.first as Map<String, dynamic>)['content_urls'];
      if (content is Map<String, dynamic>) {
        final desktop = content['desktop'];
        if (desktop is Map<String, dynamic>) url = desktop['page'] as String?;
      }
    }

    return HistoryItem(
      year: year,
      month: month,
      day: day,
      title: text,
      category: category,
      link: url,
    );
  }

  /// 内置格式：短名 {y,t,c,u} 或 长名 {year,title,category,link}
  factory HistoryItem.builtin(Map<String, dynamic> e, int month, int day) {
    final year = e['y'] ?? e['year'];
    final title = e['t'] ?? e['title'];
    final cat = e['c'] ?? e['category'];
    final link = e['u'] ?? e['link'];

    return HistoryItem(
      year: int.tryParse(year?.toString() ?? '0') ?? 0,
      month: month,
      day: day,
      title: (title as String? ?? '').trim(),
      category: cat as String? ?? '大事件',
      link: link as String?,
    );
  }
}
