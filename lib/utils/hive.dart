import 'package:hive/hive.dart';

class HiveDataBase {
  late Box box;
  List habitList = [];

  // Initialize or load the data from Hive
  void loadData() {
    box = Hive.box('habits_box');

    if (box.get('habits') == null) {
      habitList = [
        [
          'Meditate',
          false,
          0,
          18
        ], // Habit name, habit started, time spent, target goal
        ['Exercise', false, 0, 36],
      ];
      updateDataBase(); // Save initial data
    } else {
      habitList = List.castFrom(box.get('habits'));
    }
  }

  // Save updated data to Hive
  void updateDataBase() {
    box.put('habits', habitList);
  }

  // Add a new habit
  void addHabit(String habitName, int targetStreak) {
    habitList.add([habitName, false, 0, targetStreak]);
    updateDataBase();
  }

  // Delete a habit by index
  void deleteHabit(int index) {
    if (index >= 0 && index < habitList.length) {
      habitList.removeAt(index);
      updateDataBase();
    }
  }

  // Modify an existing habit by index
  void modifyHabit(int index, {String? newName, int? newTargetStreak}) {
    if (index >= 0 && index < habitList.length) {
      if (newName != null) {
        habitList[index][0] = newName; // Update habit name
      }
      if (newTargetStreak != null) {
        habitList[index][3] = newTargetStreak; // Update target streak
      }
      updateDataBase();
    }
  }

  // Mark a habit as completed and update the streak
  void completeHabit(int index, int timeSpent) {
    if (index >= 0 && index < habitList.length) {
      habitList[index][1] = true; // Mark as completed
      habitList[index][2] = timeSpent; // Save time spent
      updateDataBase();
    }
  }

  // Pause a habit and save the stopped time
  void pauseHabit(int index) {
    if (index >= 0 && index < habitList.length) {
      habitList[index][1] = false; // Mark as paused
      updateDataBase();
    }
  }
}
