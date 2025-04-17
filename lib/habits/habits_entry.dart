// lib/habits/habits_entry.dart
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'habits_model.dart';

class HabitsEntry extends StatelessWidget {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  HabitsEntry({super.key}) {
    _nameController.addListener(() {
      habitsModel.entryBeingEdited!.name = _nameController.text;
    });
    _descController.addListener(() {
      habitsModel.entryBeingEdited!.description = _descController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<HabitsModel>(
      model: habitsModel,
      child: ScopedModelDescendant<HabitsModel>(
        builder: (context, child, model) {
          _nameController.text = model.entryBeingEdited?.name ?? '';
          _descController.text = model.entryBeingEdited?.description ?? '';
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      model.stopEditingEntry();
                    },
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _save(context, model),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Habit Name'),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Please enter a name';
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(hintText: 'Description'),
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _save(BuildContext context, HabitsModel model) {
    if (!_formKey.currentState!.validate()) return;
    model.stopEditingEntry(save: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit Saved'), backgroundColor: Colors.green, duration: Duration(seconds:2)),
    );
  }
}
