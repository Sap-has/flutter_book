// lib/habits/habits_list.dart
import 'dart:async';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:badges/badges.dart';
import 'habits_model.dart';

class HabitsList extends StatefulWidget {
  const HabitsList({super.key});

  @override
  State<HabitsList> createState() => _HabitsListState();
}

class _HabitsListState extends State<HabitsList> {
  int? longPressIndex;
  double progressValue = 0.0;
  Timer? progressTimer;

  @override
  void dispose() {
    progressTimer?.cancel();
    super.dispose();
  }

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
          body: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final isBeingPressed = longPressIndex == index;

              return GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    longPressIndex = index;
                    progressValue = 0.0;
                  });

                  // Start progress timer
                  progressTimer?.cancel();
                  progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
                    if (longPressIndex == index) {
                      setState(() {
                        progressValue += 0.01;  // Increment by 1% every 30ms
                      });

                      if (progressValue >= 1.0) {
                        timer.cancel();
                        progressValue = 0.0;
                        longPressIndex = null;

                        // Show delete dialog
                        showDialog(
                          context: context,
                          builder: (alertContext) => AlertDialog(
                            title: const Text('Delete Habit'),
                            content: Text('Really delete "${habit.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(alertContext);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );

                                  // Delete the habit
                                  await model.deleteEntry(habit);

                                  // Close both dialogs
                                  Navigator.pop(context);
                                  Navigator.pop(alertContext);

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Habit deleted'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  });
                },
                onTapUp: (_) {
                  if (longPressIndex == index) {
                    progressTimer?.cancel();
                    setState(() {
                      longPressIndex = null;
                      progressValue = 0.0;
                    });
                  }
                },
                onTapCancel: () {
                  if (longPressIndex == index) {
                    progressTimer?.cancel();
                    setState(() {
                      longPressIndex = null;
                      progressValue = 0.0;
                    });
                  }
                },
                onTap: () {
                  if (progressValue < 0.5) { // Only toggle if we haven't pressed too long
                    habit.toggleComplete(model);
                  }
                },
                child: Stack(
                  children: [
                    badge.Badge(
                      badgeContent: Text('${habit.streak}'),
                      position: BadgePosition.topEnd(top: 0, end: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      habit.name ?? 'Unnamed Habit',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (habit.description != null)
                                Expanded(
                                  child: Text(
                                    habit.description!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    onPressed: () => model.startEditingEntry(habit),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  habit.completedToday
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : const Icon(Icons.circle_outlined),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isBeingPressed)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                          minHeight: 4,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}