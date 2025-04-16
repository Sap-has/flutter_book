import 'dart:io';

import 'package:flutterbook/base_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'tasks_model.dart';

class TasksDBWorker implements EntryDBWorker<Task> {
  static final TasksDBWorker db = TasksDBWorker._();

  static const String DB_Name = 'tasks.db';
  static const String TBL_Name = 'tasks';
  static const String KEY_ID = 'id';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_DUE_DATE = 'dueDate';
  static const String KEY_COMPLETED = 'completed';

  Database? _db;

  TasksDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);

    return await openDatabase(DB_Name,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE IF NOT EXISTS $TBL_Name ('
                  '$KEY_ID INTEGER PRIMARY KEY,'
                  '$KEY_DESCRIPTION TEXT,'
                  '$KEY_DUE_DATE INTEGER,'
                  '$KEY_COMPLETED INTEGER'
                  ')'
          );
        }
    );
  }

  @override
  Future<int> create(Task task) async {
    Database db = await database;
    return await db.rawInsert(
        'INSERT INTO $TBL_Name ($KEY_DESCRIPTION, $KEY_DUE_DATE, $KEY_COMPLETED) '
            'VALUES (?, ?, ?)',
      [task.description, task.dueDateInUnix ?? -1, task.completed ? 1 : 0]
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_Name, where: '$KEY_ID = ?', whereArgs: [id]);
  }

  @override
  Future<Task?> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_Name, where: '$KEY_ID = ?',
    whereArgs: [id]);
    return values.isEmpty ? null : _taskFromMap(values.first);
  }

  @override
  Future<List<Task>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_Name);
    return values.isNotEmpty ? values.map((m) => _taskFromMap(m)).toList() : [];
  }

  @override
  Future<void> update(Task task) async {
    Database db = await database;
    await db.update(TBL_Name, _taskToMap(task),
    where: '$KEY_ID = ?', whereArgs: [task.id]);
  }

  Task _taskFromMap(Map<String, dynamic> map) => Task(id: map[KEY_ID],
  description: map[KEY_DESCRIPTION],
  completed: map[KEY_COMPLETED] != 0)
      ..dueDateInUnix = map[KEY_DUE_DATE] >= 0 ? map[KEY_DUE_DATE] : null;

  Map<String, dynamic> _taskToMap(Task task) => <String, dynamic> {}
      ..[KEY_ID] = task.id
      ..[KEY_DESCRIPTION] = task.description
      ..[KEY_DUE_DATE] = task.dueDateInUnix ?? -1
      ..[KEY_COMPLETED] = task.completed ? 1 : 0;
}