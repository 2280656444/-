class ScheduleModel {
  final int? id;
  final String title;
  final String? note;
  final DateTime start;
  final DateTime? end;
  final bool allDay;
  final String? color;

  ScheduleModel({
    this.id,
    required this.title,
    this.note,
    required this.start,
    this.end,
    this.allDay = false,
    this.color,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'start': start.millisecondsSinceEpoch,
        'end': end?.millisecondsSinceEpoch,
        'allDay': allDay ? 1 : 0,
        'color': color,
      };

  factory ScheduleModel.fromMap(Map<String, Object?> m) => ScheduleModel(
        id: m['id'] as int?,
        title: m['title'] as String,
        note: m['note'] as String?,
        start: DateTime.fromMillisecondsSinceEpoch(m['start'] as int),
        end: m['end'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['end'] as int),
        allDay: (m['allDay'] as int? ?? 0) == 1,
        color: m['color'] as String?,
      );
}
