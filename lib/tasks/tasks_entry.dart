import 'package:flutter/material.dart';
import 'package:flutterbook/tasks/tasks_model.dart';
import 'package:scoped_model/scoped_model.dart';

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext context, Widget? child, TasksModel model) {
              _descriptionEditingController.text = model.entryBeingEdited?.description ?? '';

              return Scaffold(
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ElevatedButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            model.stopEditingEntry();
                          },
                      ),
                      const Spacer(),
                      ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () {
                            _save(context, model);
                          },
                      )
                    ],
                  ),
                ),
                body: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.content_paste),
                        title: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 8,
                          decoration: InputDecoration(hintText: 'Description'),
                          controller: _descriptionEditingController,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        )
                      ),
                      ListTile(
                        leading: const Icon(Icons.today),
                        title: const Text('Due Date'),
                        subtitle: _dueDate(model.entryBeingEdited),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () async => _editDueDate(context, model),
                        ),
                      )
                    ],
                  )
                ),
              );
            }
        )
    );
  }

  Text? _dueDate(Task? task) {
    final date = task?.formattedDueDate;
    return date != null ? Text(date) : null;
  }

  Future<void> _editDueDate(BuildContext context, TasksModel model) async {
    DateTime? chosenDate = await _selectDate(context,
        model.entryBeingEdited!.dueDate);
    if(chosenDate != null) {
      model.entryBeingEdited!.dueDate = chosenDate;
      model.refreshUI();
    }
  }

  void _save(BuildContext context, TasksModel model) async {
    if(!_formKey.currentState!.validate()) {
      return;
    }

    model.stopEditingEntry(save: true);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text('Task saved'),
        )
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? date) async {
    DateTime? initialDate = date ?? DateTime.now();
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    return picked;
  }
}