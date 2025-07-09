// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  static const _databaseName = "KalenderApp.db";
  static const _databaseVersion =
      1; // Kita reset ke versi 1 untuk instalasi bersih

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
      onCreate: _onCreate, // Cukup gunakan onCreate untuk instalasi baru
    );
  }

  // Fungsi ini HANYA akan berjalan jika database belum ada di perangkat.
  // Ini adalah satu-satunya tempat kita membuat tabel.
  Future<void> _onCreate(Database db, int version) async {
    // Membuat tabel events
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT, 
        description TEXT, 
        date TEXT,
        startTime TEXT, 
        endTime TEXT, 
        colorValue INTEGER
      )
    ''');

    // Membuat tabel todos
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
