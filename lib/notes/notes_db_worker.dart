import 'dart:ui';
import "package:sqflite/sqflite.dart";
import 'notes_model.dart';

abstract interface class NotesDBWorker {


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

class _MemoryNotesDBWorker implements NotesDBWorker {
  static const _TEST = true;

  _MemoryNotesDBWorker._() {
    if(_TEST && _notes.isEmpty) {
      var note = Note()
          ..title = 'Excersice: P2.3 Persistence'
          ..content = 'Code database.'
          ..color = Colors.blue;
      create(note);
    }
  }

  @override
  Future<int> create(Note note) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Note?> get(int id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List<Note>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<void> update(Note note) {
    // TODO: implement update
    throw UnimplementedError();
  }
}