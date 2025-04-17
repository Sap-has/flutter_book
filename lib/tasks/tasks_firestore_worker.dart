import 'package:flutterbook/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tasks_model.dart';
import 'package:intl/intl.dart';

class FirestoreTasksWorker implements EntryDBWorker<Task> {
  static final FirestoreTasksWorker db = FirestoreTasksWorker._();
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('tasks');

  FirestoreTasksWorker._();

  @override
  Future<int> create(Task task) async {
    final int newId = DateTime.now().millisecondsSinceEpoch;

    // 2. write under that ID (as a string)
    await _col.doc(newId.toString()).set({
      'id':          newId,
      'description': task.description,
      'due_date':    task.formattedDate,
      'completed':   task.completed,
    });

    return newId;
  }

  @override
  Future<Task?> get(int id) async {
    final doc = await _col.doc(id.toString()).get();
    if (!doc.exists) return null;
    return _taskFromDoc(doc);
  }

  @override
  Future<List<Task>> getAll() async {
    final snap = await _col.get();
    return snap.docs.map(_taskFromDoc).toList();
  }

  @override
  Future<void> update(Task task) async {
    final String docId = task.id.toString();
    await _col.doc(docId).set({
      'id':          task.id,
      'description': task.description,
      'due_date':    task.formattedDueDate,
      'completed':   task.completed
    });
  }

  @override
  Future<void> delete(int id) async {
    await _col.doc(id.toString()).delete();
  }

  Task _taskFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    DateTime? date;

    if(data['due_date'] != null) {
      try {
        // Use the correct format pattern for your date strings
        date = DateFormat('MMM d, yyyy').parse(data['due_date'] as String);
      } catch (e) {
        print('Error parsing date: ${e.toString()}');
        // Try an alternative format if the first one fails
        try {
          date = DateFormat('MMMM d, yyyy').parse(data['due_date'] as String);
        } catch (e) {
          print('Error parsing date with alternative format: ${e.toString()}');
        }
      }
    }

    return Task(
      id:          data['id'] as int,  // read the stored int
      description: data['description'] as String?,
      dueDate:     date,
      completed:   data['completed'],
    );
  }
}