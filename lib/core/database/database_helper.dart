// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  static const _databaseName = "KalenderApp.db";
  // NOTE: Jika aplikasi sudah production, versi harus dinaikkan dan dibuatkan onUpgrade
  static const _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT, 
        description TEXT, 
        date TEXT,
        startTime TEXT, 
        endTime TEXT, 
        colorValue INTEGER,
        -- --- TAMBAHAN BARU ---
        recurrenceType TEXT,
        untilDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        dueDate TEXT,
        reminderTime TEXT
      )
    ''');
  }
}
