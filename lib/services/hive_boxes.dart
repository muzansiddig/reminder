import 'package:hive/hive.dart';
import '../models/reminder.dart';

class HiveBoxes {
  static const String reminderBox = "reminder_box";

  static Box<Reminder> getReminders() =>
      Hive.box<Reminder>(reminderBox);
}
