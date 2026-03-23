import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._privateConstructor();

  static final AppDatabase instance = AppDatabase._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = join(dbPath, 'habit_mastery_v2.db');

    return openDatabase(
      dbFilePath,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        targetDays INTEGER,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        id TEXT PRIMARY KEY,
        habitId TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS habit_logs');
    await db.execute('DROP TABLE IF EXISTS habits');
    await _createDB(db, newVersion);
  }
}
