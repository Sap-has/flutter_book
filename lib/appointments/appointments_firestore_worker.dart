import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../base_model.dart';
import 'appointments_model.dart';

class FirestoreAppointmentsWorker implements EntryDBWorker<Appointment> {
  static final FirestoreAppointmentsWorker db = FirestoreAppointmentsWorker._();
  final CollectionReference<Map<String, dynamic>> _col =
    FirebaseFirestore.instance.collection('appointments');

  FirestoreAppointmentsWorker._();

  @override
  Future<int> create(Appointment app) async {
    // 1. generate a numeric ID
    final int newId = DateTime.now().millisecondsSinceEpoch;

    // 2. write under that ID (as a string)
    await _col.doc(newId.toString()).set({
      'id':          newId,
      'title':       app.title,
      'description': app.description,
      'date':        app.formattedDate,
      'time':        app.formattedTime,
    });

    // 3. return the numeric ID
    return newId;
  }

  @override
  Future<Appointment?> get(int id) async {
    final doc = await _col.doc(id.toString()).get();
    if (!doc.exists) return null;
    return _appointmentFromDoc(doc);
  }

  @override
  Future<List<Appointment>> getAll() async {
    final snap = await _col.get();
    return snap.docs.map(_appointmentFromDoc).toList();
  }

  @override
  Future<void> update(Appointment app) async {
    final String docId = app.id.toString();
    await _col.doc(docId).set({
      'id':          app.id,
      'title':       app.title,
      'description': app.description,
      'date':        app.formattedDate,
      'time':        app.formattedTime,
    });
  }

  @override
  Future<void> delete(int id) async {
    await _col.doc(id.toString()).delete();
  }

  Appointment _appointmentFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // Parse the date and time strings back to DateTime objects
    DateTime? date;
    DateTime? time;

    if (data['date'] != null) {
      try {
        // Use the correct format pattern for your date strings
        date = DateFormat('MMM d, yyyy').parse(data['date'] as String);
      } catch (e) {
        print('Error parsing date: ${e.toString()}');
        // Try an alternative format if the first one fails
        try {
          date = DateFormat('MMMM d, yyyy').parse(data['date'] as String);
        } catch (e) {
          print('Error parsing date with alternative format: ${e.toString()}');
        }
      }
    }

    if (data['time'] != null) {
      try {
        time = DateFormat('h:mm a').parse(data['time'] as String);
      } catch (e) {
        print('Error parsing time: ${e.toString()}');
      }
    }

    return Appointment(
      id:          data['id'] as int,  // read the stored int
      title:       data['title'] as String?,
      description: data['description'] as String?,
      date:        date,
      time:        time,
    );
  }
}
