class AnniversaryModel {
  final int? id;
  final String title;
  final DateTime date;
  final bool lunar;
  final String? repeatType;

  AnniversaryModel({
    this.id,
    required this.title,
    required this.date,
    this.lunar = false,
    this.repeatType = 'year',
  });

  int daysLeft() {
    final now = DateTime.now();
    var next = DateTime(now.year, date.month, date.day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, date.month, date.day);
    }
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'date': date.millisecondsSinceEpoch,
        'lunar': lunar ? 1 : 0,
        'repeatType': repeatType,
      };

  factory AnniversaryModel.fromMap(Map<String, Object?> m) => AnniversaryModel(
        id: m['id'] as int?,
        title: m['title'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        lunar: (m['lunar'] as int? ?? 0) == 1,
        repeatType: m['repeatType'] as String?,
      );

  AnniversaryModel copyWith({
    int? id,
    String? title,
    DateTime? date,
    bool? lunar,
    String? repeatType,
  }) =>
      AnniversaryModel(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        lunar: lunar ?? this.lunar,
        repeatType: repeatType ?? this.repeatType,
      );
}
