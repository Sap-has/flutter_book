import 'package:flutter/material.dart';
import 'package:flutterbook/appointments/appointments.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_model.dart';

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry({super.key}) {
    _titleEditingController.addListener(() {
      appointmentsModel.entryBeingEdited!.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entryBeingEdited!.description =
          _descriptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
        model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
          builder: (BuildContext context, Widget? child, AppointmentsModel model) {
            _titleEditingController.text = model.entryBeingEdited?.title ?? '';
            _descriptionEditingController.text = model.entryBeingEdited?.description ?? '';
            
            return Scaffold(
              bottomNavigationBar: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    ElevatedButton(
                        child: Text('Canel'),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          model.stopEditingEntry();
                        },
                    ),
                    Spacer(),
                    ElevatedButton(
                      child: Text('Save'),
                      onPressed: () => _save(context, model),
                    )
                  ],
                ),
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.title),
                      title: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Title'),
                        controller: _titleEditingController,
                        validator: (String? value) {
                          if(value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        }
                        ),
                      ),
                    ListTile(
                      leading: const Icon(Icons.content_paste),
                      title: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: 'Description'),
                        controller: _descriptionEditingController,
                        validator: (String? value) {
                          if(value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        }
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.today),
                      title: const Text('Date'),
                      subtitle: model.entryBeingEdited?.dateAsText,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => model.entryBeingEdited?.pickDate(context, model),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.alarm),
                      title: const Text('Time'),
                      subtitle: model.entryBeingEdited?.timeAsText,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => model.entryBeingEdited?.pickTime(context, model),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
      ),
    );
  }
  void _save(BuildContext context, AppointmentsModel model) async {
    if(!_formKey.currentState!.validate()) {
      return;
    }
    model.stopEditingEntry(save: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2), content: Text('Appointment Saved'),
      )
    );
  }
}



extension _AppointmentExtension on Appointment {
  Text? get timeAsText => hasTime ? Text(formattedTime!) : null;
  Text? get dateAsText => hasDate ? Text(formattedDate!) : null;

  Future<void> pickDate(BuildContext context, AppointmentsModel model) async {
    DateTime? chosenDate = await _selectDate(context, date);
    if(chosenDate != null) {
      date = chosenDate;
      model.refreshUI();
    }
  }

  Future<void> pickTime(BuildContext context, AppointmentsModel model) async {
    TimeOfDay initialTime = hasTime
    ? TimeOfDay(hour: time!.hour, minute: time!.minute) : TimeOfDay.now();

    TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime);

    if(picked != null) {
      model.entryBeingEdited!.time = _toDateTime(picked);
      model.refreshUI();
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? date) async =>
    await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100)
    );

    DateTime _toDateTime(TimeOfDay timeOfDay) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    }
}
