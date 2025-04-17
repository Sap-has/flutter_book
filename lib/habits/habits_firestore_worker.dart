// lib/habits/habits_firestore_worker.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../base_model.dart';
import 'habits_model.dart';

class FirestoreHabitsWorker implements EntryDBWorker<Habit> {
  static final FirestoreHabitsWorker db = FirestoreHabitsWorker._();
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('habits');

  FirestoreHabitsWorker._();

  @override
  Future<int> create(Habit habit) async {
    final int newId = DateTime.now().millisecondsSinceEpoch;
    await _col.doc(newId.toString()).set({
      'id': newId,
      'name': habit.name,
      'description': habit.description,
      'streak': habit.streak,
      'lastCompleted': habit.lastCompleted != null ? DateFormat('yyyy-MM-dd').format(habit.lastCompleted!) : null,
      'created': DateFormat('yyyy-MM-dd').format(habit.created),
    });
    return newId;
  }

  @override
  Future<Habit?> get(int id) async {
    final doc = await _col.doc(id.toString()).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    DateTime? last;
    if (data['lastCompleted'] != null) {
      last = DateFormat('yyyy-MM-dd').parse(data['lastCompleted'] as String);
    }
    DateTime created = DateFormat('yyyy-MM-dd').parse(data['created'] as String);
    return Habit(
      id: data['id'] as int,
      name: data['name'] as String?,
      description: data['description'] as String?,
      created: created,
      lastCompleted: last,
      streak: (data['streak'] as int?) ?? 0,
    );
  }

  @override
  Future<List<Habit>> getAll() async {
    final snap = await _col.get();
    return snap.docs.map((doc) {
      final data = doc.data();
      DateTime? last;
      if (data['lastCompleted'] != null) {
        last = DateFormat('yyyy-MM-dd').parse(data['lastCompleted'] as String);
      }
      DateTime created = DateFormat('yyyy-MM-dd').parse(data['created'] as String);
      return Habit(
        id: data['id'] as int,
        name: data['name'] as String?,
        description: data['description'] as String?,
        created: created,
        lastCompleted: last,
        streak: (data['streak'] as int?) ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> update(Habit habit) async {
    await _col.doc(habit.id.toString()).set({
      'id': habit.id,
      'name': habit.name,
      'description': habit.description,
      'streak': habit.streak,
      'lastCompleted': habit.lastCompleted != null ? DateFormat('yyyy-MM-dd').format(habit.lastCompleted!) : null,
      'created': DateFormat('yyyy-MM-dd').format(habit.created),
    });
  }

  @override
  Future<void> delete(int id) async {
    await _col.doc(id.toString()).delete();
  }
}
