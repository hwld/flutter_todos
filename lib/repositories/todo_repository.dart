import 'package:flutter_todo_list/models/todo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoRepository {
  TodoRepository({required String dbPath}) {
    this._database = openDatabase(
      join(dbPath, 'todo_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id TEXT PRIMARY KEY, title TEXT, isComplete BOOLEAN)',
        );
      },
      version: 1,
    );
  }

  late Future<Database> _database;

  // todoMapをDB用のmapに変換する
  Map<String, dynamic> convertToDBTodoMap(Map<String, dynamic> todoMap) {
    return todoMap.map((key, value) {
      if (key == 'isComplete') {
        if (value == true) {
          return MapEntry(key, 1);
        } else if (value == false) {
          return MapEntry(key, 0);
        } else {
          throw Error();
        }
      }
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> convertToTodoMap(Map<String, dynamic> todoMap) {
    return todoMap.map((key, value) {
      if (key == 'isComplete') {
        if (value == 1) {
          return MapEntry(key, true);
        } else if (value == 0) {
          return MapEntry(key, false);
        } else {
          throw Error();
        }
      }
      return MapEntry(key, value);
    });
  }

  Future<void> insertTodo(Todo todo) async {
    final db = await _database;
    final todoMap = convertToDBTodoMap(todo.toMap());

    await db.insert(
      'todos',
      todoMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> todos() async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
      final dbTodoMap = convertToTodoMap(maps[i]);
      return Todo(
        id: dbTodoMap['id'],
        title: dbTodoMap['title'],
        isComplete: dbTodoMap['isComplete'],
      );
    });
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await _database;
    final todoMap = convertToDBTodoMap(todo.toMap());

    await db.update(
      'todos',
      todoMap,
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(String id) async {
    final db = await _database;

    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
