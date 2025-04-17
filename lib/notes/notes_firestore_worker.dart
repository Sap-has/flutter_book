import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../base_model.dart';
import 'notes_model.dart';

class FirestoreNotesWorker implements EntryDBWorker<Note> {
  static final FirestoreNotesWorker db = FirestoreNotesWorker._();
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('notes');

  FirestoreNotesWorker._();

  @override
  Future<int> create(Note note) async {
    // 1. generate a numeric ID
    final int newId = DateTime.now().millisecondsSinceEpoch;

    // 2. write under that ID (as a string)
    await _col.doc(newId.toString()).set({
        'id':          newId,
        'title':       note.title,
        'content':     note.content,
        'color':       note.colorName
      });

    // 3. return the numeric ID
    return newId;
  }

  @override
  Future<Note?> get(int id) async {
    final doc = await _col.doc(id.toString()).get();
    if (!doc.exists) return null;
    return _noteFromDoc(doc);
  }

  @override
  Future<List<Note>> getAll() async {
    final snap = await _col.get();
    return snap.docs.map(_noteFromDoc).toList();
  }

  @override
  Future<void> update(Note note) async {
    final String docId = note.id.toString();
    await _col.doc(docId).set({
      'id':          note.id,
      'title':       note.title,
      'content':     note.content,
      'color':       note.colorName
    });
  }

  @override
  Future<void> delete(int id) async {
    await _col.doc(id.toString()).delete();
  }

  Note _noteFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    Color color = Colors.white;

    if (data['color'] != null) {
      try {
        Note tempNote = Note(color: Colors.white);
        tempNote.colorName = data['color'] as String;
        color = tempNote.color;
      } catch (e) {
        print('Error parsing color: ${e.toString()}');
      }
    }

    return Note(
      id:          data['id'] as int,  // read the stored int
      title:       data['title'] as String?,
      content:     data['content'] as String?,
      color:       color,
    );
  }
}