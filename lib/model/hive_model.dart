import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isRunning;

  @HiveField(2)
  int timeSpent;

  @HiveField(3)
  int timeGoal;

  Habit({
    required this.name,
    required this.isRunning,
    required this.timeSpent,
    required this.timeGoal,
  });
}
