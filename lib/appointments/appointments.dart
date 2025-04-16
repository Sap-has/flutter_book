import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_entry.dart';
import 'appointments_list.dart';
import 'appointments_model.dart';

class Appointments extends StatelessWidget {
  const Appointments({super.key});

  @override
  Widget build(BuildContext context) {
    appointmentsModel.loadData();
    return ScopedModel<AppointmentsModel>(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
            builder: (BuildContext context, Widget? child, AppointmentsModel model) {
              return IndexedStack(
                index: model.stackIndex,
                children: <Widget>[AppointmentsList(), AppointmentsEntry()],
              );
            }
        )
    );
  }
}