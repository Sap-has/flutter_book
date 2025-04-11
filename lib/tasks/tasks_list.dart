import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'tasks_model.dart';

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext context, Widget? child, TasksModel model) {
              return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => model.startEditingEntry(Task()),
                  ),
                  body: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      itemCount: model.entryList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Task task = model.entryList[index];
                        return Container(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Slidable(
                              endActionPane: ActionPane(
                                extentRatio: 0.25,
                                motion: const ScrollMotion(),
                                children: <Widget>[
                                  SlidableAction(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    label: 'Delete',
                                    icon: Icons.delete,
                                    onPressed: (context) => task.delete(context),
                                  )
                                ],
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                    value: task.completed,
                                    onChanged: (bool? value) async =>
                                        task.updateCompletion(value, model)),
                                title: task.styledDescription(context),
                                subtitle: task.styledDueDate(context),
                                onTap: () async => task.edit(model),
                              )),
                        );
                      }));
            }));
  }
}

extension _TaskExtension on Task {
  Text? styledDescription(BuildContext context) =>
      _styledText(description, context);

  Text? styledDueDate(BuildContext context) =>
      _styledText(formattedDueDate, context);

  Future<void> updateCompletion(bool? checked, TasksModel model) async {
    completed = checked ?? false;
    model.updateEntry(this);
  }

  Future<void> edit(TasksModel model) async {
    if(!completed) {
      model.startEditingEntry(this);
    }
  }

  Future<void> delete(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Really delete $description?'),
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
                await tasksModel.deleteEntry(this);
                Navigator.of(alertContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                  content: Text('Task Deleted'),
                ));
              },
            )
          ]
        );
      }
    );
  }

  Text? _styledText(String? text, BuildContext context) =>
      text == null ? null : Text(text, style: _textStyle(context));

  TextStyle _textStyle(BuildContext context) {
    return completed
        ? TextStyle(
      color: Theme.of(context).disabledColor,
      decoration: TextDecoration.lineThrough)
        : TextStyle(color: Theme.of(context).textTheme.titleLarge!.color);
  }
}
