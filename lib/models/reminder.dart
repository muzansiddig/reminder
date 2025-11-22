import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? notes;

  @HiveField(2)
  DateTime dateTime;

  Reminder({
    required this.title,
    this.notes,
    required this.dateTime,
  });
}
