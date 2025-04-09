import 'package:flutter/material.dart';
import 'notes_db_worker.dart';
import 'package:scoped_model/scoped_model.dart';

final NotesModel notesModel = NotesModel();

class Note {
  int? id;
  String? title;
  String? content;
  Color color = Colors.white;

  static List<Color> get allColors => _colorMap.values.toList();

  static const _colorMap = {
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'grey': Colors.grey,
    'purple': Colors.purple,
  };

  String get colorName {
    for (var entry in _colorMap.entries) {
      if (entry.value == color) {
        return entry.key;
      }
    }
    return 'white';
  }

  set colorName(String name) => color = _colorMap[name] ?? Colors.white;

  Note({id = -1});
  bool get isNew => id == null || id == -1;
}

class NotesModel extends Model {
  int _stackIndex = 0;  // 0 or 1 for list or entry screen
  final List<Note> noteList = [];
  Note? noteBeingEdited;

  int get stackIndex => _stackIndex;

  final NotesDBWorker database;

  NotesModel(): database = NotesDBWorker.db;

  void loadData() async {
    noteList.clear();
    noteList.addAll(await database.getAll());
    notifyListeners();
  }

  set stackIndex(int index) {
    _stackIndex = index;
    notifyListeners();
  }

  void startEditingNote(Note note) {
    noteBeingEdited = note;
    stackIndex = 1; // navigate to entry screen
  }

  void stopEditingNote({bool save=false}) async {
    if (save && noteBeingEdited != null) {
      // Ensure we have valid values before saving
      noteBeingEdited!.title = noteBeingEdited!.title ?? '';
      noteBeingEdited!.content = noteBeingEdited!.content ?? '';

      try {
        if (noteBeingEdited!.isNew) {
          await database.create(noteBeingEdited!);
        } else {
          await database.update(noteBeingEdited!);
        }
        // Reload data from database to ensure UI is up to date
        loadData();
      } catch (e) {
        print('Error saving note: $e');
        // You might want to handle errors more gracefully here
      }
    }
    noteBeingEdited = null;
    stackIndex = 0; // navigate to list screen
  }

  Color? get color => noteBeingEdited?.color;

  set color(Color? color) {
    assert(noteBeingEdited != null);
    noteBeingEdited!.color = color!;
    notifyListeners();
  }

  void deleteNote(Note note) async {
    if (!note.isNew) {
      await database.delete(note.id!);
    }
    noteList.remove(note);
    notifyListeners();
  }
}
