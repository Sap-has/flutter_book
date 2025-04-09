import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notes_model.dart';
import 'notes_list.dart';
import 'notes_entry.dart';

class Notes extends StatelessWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize model and load data
    notesModel.loadData();

    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
            builder: (BuildContext context, Widget? child, NotesModel model) {
              return IndexedStack(
                index: model.stackIndex,
                children: <Widget>[NotesList(), NotesEntry()],
              );
            }
        )
    );
  }
}