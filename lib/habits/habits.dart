// lib/habits/habits.dart
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'habits_entry.dart';
import 'habits_list.dart';
import 'habits_model.dart';

class Habits extends StatelessWidget {
  const Habits({super.key});

  @override
  Widget build(BuildContext context) {
    habitsModel.loadData();
    return ScopedModel<HabitsModel>(
      model: habitsModel,
      child: ScopedModelDescendant<HabitsModel>(
        builder: (context, child, model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              const HabitsList(),
              HabitsEntry(),
            ],
          );
        },
      ),
    );
  }
}