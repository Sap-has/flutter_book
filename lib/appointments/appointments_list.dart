import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import '../base_model.dart' show DateMixin;
import 'appointments_model.dart';

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppointmentsModel>(builder:
        (BuildContext context, Widget? child, AppointmentsModel model) {
        EventList<Event> markedDateMap = EventList<Event>(events: {});
        for(Appointment app in appointmentsModel.entryList) {
          if(app.date != null) {
            markedDateMap.add(
              app.date!,
              Event(
                date: app.date!,
              )
            );
          }
        }
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => model.startEditingEntry(Appointment()),
          ),
          body: Column(
            children: <Widget>[
              Expanded(child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: CalendarCarousel<Event>(
                  thisMonthDayBorderColor: Colors.grey,
                  daysHaveCircularBorder: false,
                  markedDatesMap: markedDateMap,
                  onDayPressed: (DateTime date, List<Event> events) async {
                    bool changed;
                    do {
                      changed = await _showAppointments(context, date);
                    } while(changed);
                  },
                ),
              ))
            ],
          ),
        );
      }
    );
  }

  Future<bool> _showAppointments(BuildContext context, DateTime date) async {
    final bool? shouldReopen = await showModalBottomSheet(
        context: context,
        builder: (BuildContext builderContext) {
          final model = ScopedModel.of<AppointmentsModel>(context);
          final appointments = model.appointmentsOn(date);
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                child: Column(
                  children: <Widget>[
                    Text(
                      DateMixin.formatDate(date),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 24,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (BuildContext context, int index) {
                          Appointment app = appointments[index];
                          return Slidable(
                            endActionPane: ActionPane(
                              extentRatio: .25,
                              motion: ScrollMotion(),
                              children: <Widget>[
                                SlidableAction(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  label: 'Delete',
                                  icon: Icons.delete,
                                  onPressed: (ctx) async {
                                    var deleted = await app.delete(context, model);
                                    if(deleted == true) {
                                      Navigator.pop(context, deleted);
                                    }
                                  },
                                )
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Colors.grey.shade300,
                              child: ListTile(
                                title: app.titleAsText,
                                subtitle: app.descriptionAsText,
                                onTap: () async => app.edit(context, model),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
    return shouldReopen == true;
  }
}

extension _AppointmentExtension on Appointment {
  Text? get titleAsText => hasTime ? Text('$title ($formattedTime)') : Text(title!);
  Text? get descriptionAsText => hasDescription ? Text(description!) : null;

  void edit(BuildContext context, AppointmentsModel model) async {
    model.startEditingEntry(this);
    Navigator.pop(context);
  }

  Future<bool?> delete(BuildContext context, AppointmentsModel model) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text('Delete Appointment'),
          content: Text('Really Delete $title?'),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(alertContext).pop();
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () async {
                await model.deleteEntry(this);
                Navigator.of(alertContext).pop(true);
                ScaffoldMessenger.of(alertContext).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                  content: Text('Appointment deleted'),
                ));
              },
            )
          ],
        );
      }
    );
  }
}