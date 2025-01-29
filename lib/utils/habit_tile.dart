import 'package:flutter/material.dart';
import 'package:habit_tracker/utils/hive.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final VoidCallback onTap; // OnTap will start or pause the habit
  final VoidCallback settingsTapped; // Settings to modify habit
  final int timeSpent; // Time spent on this habit in seconds
  final int timeGoal; // Goal for this habit in minutes
  final bool habitStarted; // Whether the habit is in progress or paused
  final int habitIndex; // Index of the habit in the habitList
  final HiveDataBase database; // HiveDataBase instance

  const HabitTile({
    super.key,
    required this.habitName,
    required this.habitStarted,
    required this.onTap,
    required this.settingsTapped,
    required this.timeGoal,
    required this.timeSpent,
    required this.habitIndex,
    required this.database,
  });

  String formatToMinSec(int totalSeconds) {
    String secs = (totalSeconds % 60).toString();
    String mins = (totalSeconds / 60).toStringAsFixed(1);

    if (secs.length == 1) {
      secs = '0$secs';
    }
    if (mins[1] == '.') {
      mins = mins.substring(0, 1);
    }
    return '$mins:$secs';
  }

  double percentCompleted() {
    return timeSpent / (timeGoal * 60);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Stack(
                      children: [
                        CircularPercentIndicator(
                          radius: 30,
                          percent:
                              percentCompleted() < 1 ? percentCompleted() : 1,
                          progressColor: percentCompleted() > 0.20
                              ? (percentCompleted() > 0.50
                                  ? Colors.green[800]
                                  : Colors.green[400])
                              : Colors.orange,
                        ),
                        Center(
                            child: Icon(
                          habitStarted ? Icons.pause : Icons.play_arrow,
                          size: 25,
                        ))
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habitName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${formatToMinSec(timeSpent)} / $timeGoal = ${(percentCompleted() * 100).toStringAsFixed(0)} %',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: settingsTapped,
              child: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}
