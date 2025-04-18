import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increment database version
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0, -- NEW COLUMN: isCompleted
        dueDate INTEGER,
        actionTime INTEGER,
        priority TEXT NOT NULL,
        category TEXT NOT NULL,
        isRecurring INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Add isCompleted column for marking tasks as completed
      await db.execute('ALTER TABLE todos ADD COLUMN isCompleted INTEGER DEFAULT 0');
    }
  }

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final result = await db.query('todos', orderBy: 'dueDate ASC');
    return result.map((json) => Todo.fromMap(json)).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}