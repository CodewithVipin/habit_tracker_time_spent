import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habit_tracker/utils/habit_tile.dart';
import 'package:habit_tracker/utils/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = HiveDataBase();

  @override
  void initState() {
    super.initState();
    db.loadData();
  }

  void habitStarted(int index) {
    DateTime startTime = DateTime.now();
    int elapsedTime = db.habitList[index][2];

    setState(() {
      db.habitList[index][1] =
          !db.habitList[index][1]; // Toggle habit started state
    });

    // If the habit is being started, start the timer.
    if (db.habitList[index][1]) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!db.habitList[index][1]) {
          timer.cancel();
        } else {
          setState(() {
            db.habitList[index][2] =
                elapsedTime + DateTime.now().difference(startTime).inSeconds;
            db.updateDataBase(); // Update the database after every second
          });
        }
      });
    } else {
      // If the habit is stopped, ensure the final time is saved.
      db.updateDataBase(); // Call updateDataBase() when habit is stopped
    }
  }

  void settingOpened(int index) {
    final habitNameController = TextEditingController(
        text: db.habitList[index][0]); // Pre-fill current habit name
    final goalController = TextEditingController(
        text: db.habitList[index][3].toString()); // Pre-fill current goal

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Settings for ${db.habitList[index][0]}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: habitNameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                ),
              ),
              TextField(
                controller: goalController,
                decoration: const InputDecoration(
                  labelText: 'Goal (min)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  db.habitList[index][0] = habitNameController.text.isEmpty
                      ? db.habitList[index][0]
                      : habitNameController.text;
                  db.habitList[index][3] = int.tryParse(goalController.text) ??
                      db.habitList[index][3];
                  db.updateDataBase();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void addHabit() {
    showDialog(
      context: context,
      builder: (context) {
        final habitNameController = TextEditingController();
        final goalController = TextEditingController();

        return AlertDialog(
          title: const Text('Add New Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: habitNameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                ),
              ),
              TextField(
                controller: goalController,
                decoration: const InputDecoration(
                  labelText: 'Goal (min)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (habitNameController.text.isNotEmpty) {
                  setState(() {
                    db.addHabit(
                      habitNameController.text,
                      int.tryParse(goalController.text) ?? 0,
                    );
                    db.updateDataBase();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void deleteHabit(int index) {
    setState(() {
      db.habitList.removeAt(index);
      db.updateDataBase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: addHabit,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Consistency is key'),
      ),
      body: db.habitList.isNotEmpty
          ? ListView.builder(
              itemCount: db.habitList.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (_) => deleteHabit(index),
                  background: Container(color: Colors.red),
                  child: HabitTile(
                    habitIndex: 1,
                    database: HiveDataBase(),
                    habitName: db.habitList[index][0],
                    habitStarted: db.habitList[index][1],
                    onTap: () => habitStarted(index),
                    settingsTapped: () => settingOpened(index),
                    timeGoal: db.habitList[index][3],
                    timeSpent: db.habitList[index][2],
                  ),
                );
              },
            )
          : Center(
              child: Text(
                "No Exercise Exist!",
                style: TextStyle(fontSize: 18),
              ),
            ),
    );
  }
}
