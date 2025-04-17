// lib/habits/habits_list.dart
import 'dart:async';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:badges/badges.dart';
import 'habits_model.dart';

class HabitsList extends StatelessWidget {
  const HabitsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<HabitsModel>(
      builder: (context, child, model) {
        final habits = model.entryList;
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => model.startEditingEntry(Habit()),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              Timer? pressTimer;
              return GestureDetector(
                onTapDown: (_) {
                  pressTimer = Timer(const Duration(seconds: 3), () {
                    showDialog(
                      context: context,
                      builder: (alertContext) => AlertDialog(
                        title: const Text('Delete Habit'),
                        content: Text('Really delete "${habit.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(alertContext);
                              pressTimer?.cancel();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await model.deleteEntry(habit);
                              Navigator.pop(alertContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Habit deleted'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  });
                },
                onTapUp: (_) => pressTimer?.cancel(),
                onTapCancel: () => pressTimer?.cancel(),
                onTap: () => habit.toggleComplete(model),
                child: badge.Badge(
                  badgeContent: Text('${habit.streak}'),
                  position: BadgePosition.topEnd(top: 0, end: 16),
                  child: Card(
                    child: ListTile(
                      title: Text(habit.name ?? 'Unnamed Habit'),
                      subtitle: habit.description != null ? Text(habit.description!) : null,
                      trailing: habit.completedToday
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.circle_outlined),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}