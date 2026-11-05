import 'package:rili/models/schedule_model.dart';
import 'db_service.dart';

class ScheduleRepo {
  static Future<List<ScheduleModel>> month(DateTime m) async {
    final db = await DbService.db;
    final s = DateTime(m.year, m.month, 1).millisecondsSinceEpoch;
    final e =
        DateTime(m.year, m.month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;
    final rows = await db.query('schedule',
        where: 'start BETWEEN ? AND ?', whereArgs: [s, e]);
    return rows.map(ScheduleModel.fromMap).toList();
  }

  static Future<int> insert(ScheduleModel m) async {
    final db = await DbService.db;
    return await db.insert('schedule', m.toMap());
  }

  static Future<void> update(ScheduleModel m) async {
    final db = await DbService.db;
    final map = Map<String, Object?>.from(m.toMap());
    final id = map.remove('id');
    await db.update('schedule', map, where: 'id=?', whereArgs: [id]);
  }

  static Future<void> delete(int id) async {
    final db = await DbService.db;
    await db.delete('schedule', where: 'id=?', whereArgs: [id]);
  }

  static Future<List<ScheduleModel>> all() async {
    final db = await DbService.db;
    final rows = await db.query('schedule', orderBy: 'start DESC');
    return rows.map(ScheduleModel.fromMap).toList();
  }
}
