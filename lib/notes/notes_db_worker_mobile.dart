import 'notes_db_worker.dart';

NotesDBWorker createNotesDBWorker() {
  return _SQLiteNotesDBWorker();
}