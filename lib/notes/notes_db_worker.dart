import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'notes_model.dart';

abstract interface class NotesDBWorker {
  // Factory constructor to return the database instance
  static final NotesDBWorker db = _SQLiteNotesDBWorker._();

  /// Create and add the given note in this database
  Future<int> create(Note note);

  /// Update the given note of this database
  Future<void> update(Note note);

  /// Delete the specified note
  Future<void> delete(int id);

  /// Return the specified or null
  Future<Note?> get(int id);

  /// Return all the notes of this database
  Future<List<Note>> getAll();
}

class _SQLiteNotesDBWorker implements NotesDBWorker {
  // Database name and table name constants
  static const String DB_NAME = 'notes.db';
  static const String TBL_NOTES = 'notes';

  // Column names
  static const String COL_ID = 'id';
  static const String COL_TITLE = 'title';
  static const String COL_CONTENT = 'content';
  static const String COL_COLOR = 'color';

  // Database instance variable
  Database? _db;

  _SQLiteNotesDBWorker._();

  // Get the database instance, creating it if needed
  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    // Initialize databaseFactory for desktop platforms
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE $TBL_NOTES ('
                '$COL_ID INTEGER PRIMARY KEY AUTOINCREMENT, '
                '$COL_TITLE TEXT, '
                '$COL_CONTENT TEXT, '
                '$COL_COLOR TEXT'
                ')'
        );
      },
    );
  }

  // Convert a Note object to a map for database operations
  Map<String, dynamic> _noteToMap(Note note) {
    Map<String, dynamic> map = <String, dynamic>{};
    map[COL_TITLE] = note.title;
    map[COL_CONTENT] = note.content;
    map[COL_COLOR] = note.colorName;
    return map;
  }

  // Convert a database map to a Note object
  Note _mapToNote(Map<String, dynamic> map) {
    Note note = Note();
    note.id = map[COL_ID] as int;
    note.title = map[COL_TITLE] as String?;
    note.content = map[COL_CONTENT] as String?;
    note.colorName = map[COL_COLOR] as String;
    return note;
  }

  @override
  Future<int> create(Note note) async {
    Database db = await database;
    int id = await db.insert(TBL_NOTES, _noteToMap(note));
    note.id = id;
    return id;
  }

  @override
  Future<void> update(Note note) async {
    Database db = await database;
    await db.update(
        TBL_NOTES,
        _noteToMap(note),
        where: '$COL_ID = ?',
        whereArgs: [note.id]
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(
        TBL_NOTES,
        where: '$COL_ID = ?',
        whereArgs: [id]
    );
  }

  @override
  Future<Note?> get(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
        TBL_NOTES,
        where: '$COL_ID = ?',
        whereArgs: [id]
    );

    if (maps.isNotEmpty) {
      return _mapToNote(maps.first);
    }
    return null;
  }

  @override
  Future<List<Note>> getAll() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(TBL_NOTES);

    return maps.map((map) => _mapToNote(map)).toList();
  }
}