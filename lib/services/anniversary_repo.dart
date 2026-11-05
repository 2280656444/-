import 'package:rili/models/anniversary_model.dart';
import 'db_service.dart';

class AnniversaryRepo {
  static Future<List<AnniversaryModel>> all() async {
    final db = await DbService.db;
    final rows = await db.query('anniversary');
    return rows.map(AnniversaryModel.fromMap).toList();
  }

  static Future<int> insert(AnniversaryModel m) async {
    final db = await DbService.db;
    return await db.insert('anniversary', m.toMap());
  }

  static Future<void> update(AnniversaryModel m) async {
    final db = await DbService.db;
    final map = Map<String, Object?>.from(m.toMap());
    final id = map.remove('id');
    await db.update('anniversary', map, where: 'id=?', whereArgs: [id]);
  }

  static Future<void> delete(int id) async {
    final db = await DbService.db;
    await db.delete('anniversary', where: 'id=?', whereArgs: [id]);
  }
}
