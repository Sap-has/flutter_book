import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

final NotesModel notesModel = NotesModel();  // to be used by UI

class Note {
  String? title;
  String? content;
  Color? color;

  static List<Color> get allColors => _colorMap.values.toList();

  static const _colorMap = {
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'grey': Colors.grey,
    'purple': Colors.purple,
  };

  String? get colorName {
    for (var entry in _colorMap.entries) {
      if (entry.value == color) {
        return entry.key;
      }
    }
    return null;
  }

  set colorName(String? name) => color = _colorMap[name];


}

class NotesModel extends Model {

  int _stackIndex = 0;  // 0 or 1  for list or entry screen
  final List<Note> noteList = [];
  Note? noteBeingEdited;

  int get stackIndex => _stackIndex;

  set stackIndex(int index) {
    _stackIndex = index;
    notifyListeners();
  }

  void startEditingNote(Note note) {
    noteBeingEdited = note;
    stackIndex = 1; // navigate to entry screen
  }

  void stopEditingNote({bool save=false}) {
    if (save &&
        !noteList.contains(noteBeingEdited!)) {
      noteList.add(noteBeingEdited!);
    }
    noteBeingEdited = null;
    stackIndex = 0; // navigate to list screen
  }

  String? get color => noteBeingEdited?.color as String;

  set color(String? color) {
    assert(noteBeingEdited != null);
    noteBeingEdited!.color = color as Color?;
    notifyListeners();
  }

}

