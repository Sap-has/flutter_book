// lib/habits/habits_model.dart
import 'package:intl/intl.dart';
import '../base_model.dart';
import 'habits_firestore_worker.dart';

HabitsModel habitsModel = HabitsModel();

class HabitsModel extends BaseModel<Habit> {
  HabitsModel() : super(FirestoreHabitsWorker.db);

  @override
  Future<void> startEditingEntry(Habit entry) async {
    if (entry.isNew) {
      entry.created = DateTime.now();
      entry.streak = 0;
      entry.lastCompleted = null;
    }
    super.startEditingEntry(entry);
  }

  void updateEntry(Habit habit) async {
    await database.update(habit);
    loadData();
  }
}

class Habit extends Entry {
  String? name;
  String? description;
  int streak;
  DateTime? lastCompleted;
  DateTime created;

  Habit({super.id = Entry.NO_ID, this.name, this.description, DateTime? created, this.lastCompleted, this.streak = 0})
      : created = created ?? DateTime.now();

  bool get hasName => name != null && name!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get completedToday {
    if (lastCompleted == null) return false;
    final now = DateTime.now();
    return lastCompleted!.year == now.year && lastCompleted!.month == now.month && lastCompleted!.day == now.day;
  }

  void toggleComplete(HabitsModel model) {
    final now = DateTime.now();
    if (completedToday) {
      lastCompleted = null;
      streak = 0;
    } else {
      if (lastCompleted != null) {
        final yesterday = now.subtract(const Duration(days: 1));
        if (lastCompleted!.year == yesterday.year && lastCompleted!.month == yesterday.month && lastCompleted!.day == yesterday.day) {
          streak += 1;
        } else {
          streak = 1;
        }
      } else {
        streak = 1;
      }
      lastCompleted = now;
    }
    model.updateEntry(this);
  }
}