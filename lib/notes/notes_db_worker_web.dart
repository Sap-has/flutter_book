import 'dart:async';
import 'dart:indexed_db';
import 'dart:convert';
import 'dart:ui';
import 'package:sqflite/sqflite.dart';
import 'notes_db_worker.dart';
import 'notes_model.dart';

NotesDBWorker createNotesDBWorker() {
  return _WebNotesDBWorker();
}

class _WebNotesDBWorker implements NotesDBWorker {
  static const String DB_NAME = 'flutter_book_db';
  static const int DB_VERSION = 1;
  static const String STORE_NAME = 'notes_store';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() {
    final completer = Completer<Database>();
    final openRequest = window.indexedDB!.open(DB_NAME, version: DB_VERSION);

    openRequest.onUpgradeNeeded.listen((event) {
      final db = openRequest.result;
      if (!db.objectStoreNames!.contains(STORE_NAME)) {
        db.createObjectStore(STORE_NAME, keyPath: 'id', autoIncrement: true);
      }
    });

    openRequest.onSuccess.listen((event) {
      completer.complete(openRequest.result);
    });

    openRequest.onError.listen((event) {
      completer.completeError('Failed to open database: ${event.toString()}');
    });

    return completer.future;
  }

  @override
  Future<int> create(Note note) async {
    final db = await database;
    final tx = db.transaction(STORE_NAME, 'readwrite');
    final store = tx.objectStore(STORE_NAME);

    final noteMap = {
      'title': note.title,
      'content': note.content,
      'color': note.colorName,
    };

    final completer = Completer<int>();

    store.add(noteMap).onSuccess.listen((event) {
      final id = event.target.result as int;
      note.id = id;
      completer.complete(id);
    });

    tx.onComplete.listen((_) {});

    return completer.future;
  }

  @override
  Future<void> update(Note note) async {
    final db = await database;
    final tx = db.transaction(STORE_NAME, 'readwrite');
    final store = tx.objectStore(STORE_NAME);

    final noteMap = {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'color': note.colorName,
    };

    final completer = Completer<void>();

    store.put(noteMap).onSuccess.listen((_) {
      completer.complete();
    });

    tx.onComplete.listen((_) {});

    return completer.future;
  }

  @override
  Future<void> delete(int id) async {
    final db = await database;
    final tx = db.transaction(STORE_NAME, 'readwrite');
    final store = tx.objectStore(STORE_NAME);

    final completer = Completer<void>();

    store.delete(id).onSuccess.listen((_) {
      completer.complete();
    });

    tx.onComplete.listen((_) {});

    return completer.future;
  }

  @override
  Future<Note?> get(int id) async {
    final db = await database;
    final tx = db.transaction(STORE_NAME, 'readonly');
    final store = tx.objectStore(STORE_NAME);

    final completer = Completer<Note?>();

    store.getObject(id).onSuccess.listen((event) {
      if (event.target.result != null) {
        final data = event.target.result as Map;
        final note = Note();
        note.id = id;
        note.title = data['title'] as String?;
        note.content = data['content'] as String?;
        note.colorName = data['color'] as String;
        completer.complete(note);
      } else {
        completer.complete(null);
      }
    });

    tx.onComplete.listen((_) {});

    return completer.future;
  }

  @override
  Future<List<Note>> getAll() async {
    final db = await database;
    final tx = db.transaction(STORE_NAME, 'readonly');
    final store = tx.objectStore(STORE_NAME);

    final completer = Completer<List<Note>>();
    final notes = <Note>[];

    store.openCursor().onSuccess.listen((event) {
      final cursor = event.target.result as Cursor?;
      if (cursor != null) {
        final data = cursor.value as Map;
        final note = Note();
        note.id = data['id'] as int;
        note.title = data['title'] as String?;
        note.content = data['content'] as String?;
        note.colorName = data['color'] as String;
        notes.add(note);
        cursor.next();
      } else {
        completer.complete(notes);
      }
    });

    tx.onComplete.listen((_) {});

    return completer.future;
  }
}