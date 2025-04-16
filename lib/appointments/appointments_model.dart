import 'package:intl/intl.dart';
import '../base_model.dart';
import 'appointments_db_worker.dart';

AppointmentsModel appointmentsModel = AppointmentsModel();

class AppointmentsModel extends BaseModel<Appointment> {
  AppointmentsModel(): super(AppointmentsDBWorker.db);

  List<Appointment> appointmentsOn(DateTime date) =>
      entryList.where((app) => app.isOnDate(date)).toList();

  @override
  Future<void> startEditingEntry(Appointment entry) async {
    if(entry.isNew) {
      entry.date = DateTime.now();
    }
    super.startEditingEntry(entry);
  }
}

class Appointment extends Entry with DateMixin {
  String? title;
  String? description;
  DateTime? time;

  Appointment({super.id = Entry.NO_ID, this.title, this.description, DateTime? date, this.time}) {
    this.date = date;
  }

  bool get hasTitle => title != null;

  bool get hasDescription => description != null;

  bool get hasTime => time != null;

  String? get formattedTime => hasTime ? formatTime(time!) : null;

  int? get timeInUnix => hasTime ? time!.millisecondsSinceEpoch : null;

  set timeInUnix(int? millis) {
    DateTime? dateTime;
    if(millis != null) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
    }
    time = dateTime;
  }

  bool isOnDate(DateTime? date) => this.date != null && date != null &&
    DateTime(this.date!.year, this.date!.month, this.date!.day) == DateTime(date.year, date.month, date.day);

  static String formatTime(DateTime time) => DateFormat('h:mm a').format(time);

  @override
  String toString() => '{id=$id, title=$title, description=$description, date=$date, time=$time}';
}