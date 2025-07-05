// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'calendar_database.db');
    return await openDatabase(
      path,
      version: 3, // <-- NAIKKAN VERSI DATABASE MENJADI 3
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createEventsTable(db);
    await _createTodosTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTodosTable(db);
    }
    // --- TAMBAHKAN BLOK INI UNTUK MENAMBAH KOLOM BARU ---
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE todos ADD COLUMN reminderTime TEXT');
    }
  }

  Future<void> _createEventsTable(Database db) async {
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT, description TEXT, date TEXT,
        startTime TEXT, endTime TEXT, colorValue INTEGER
      )
    ''');
  }

  Future<void> _createTodosTable(Database db) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        dueDate TEXT
      )
    ''');
  }
}
