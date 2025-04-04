import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'notes_model.dart';

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget? child, NotesModel model) {
          return Scaffold(
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () => model.startEditingNote(Note())),
              body: ListView.builder(
                  itemCount: model.noteList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Note note = model.noteList[index];
                    return Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Card(
                            elevation: 8,
                            color: note.color,
                            child: ListTile(
                              title: Text(note.title ?? ''),
                              subtitle: Text(note.content ?? ''),
                              onTap: () => model.startEditingNote(note),
                            )
                        )
                    );
                  }
              )
          );
        }
    );
  }
}