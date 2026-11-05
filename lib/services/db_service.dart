import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    final p = join(await getDatabasesPath(), 'rili.db');
    _db = await openDatabase(
      p,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE schedule(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT, note TEXT,
            start INTEGER, end INTEGER,
            allDay INTEGER, color TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE anniversary(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT, date INTEGER,
            lunar INTEGER, repeatType TEXT
          )
        ''');
      },
    );
    return _db!;
  }
}
