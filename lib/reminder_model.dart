import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 0)
enum ReminderType {
  @HiveField(0)
  time,
  @HiveField(1)
  location,
}

@HiveType(typeId: 1)
enum ReminderCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  shopping,
  @HiveField(3)
  health,
}

@HiveType(typeId: 2)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  int? dueHour;

  @HiveField(5)
  int? dueMinute;

  @HiveField(6)
  ReminderType type;

  @HiveField(7)
  String? location;

  @HiveField(8)
  ReminderCategory category;

  @HiveField(9)
  bool isCompleted;

  @HiveField(10)
  bool isFavorite;

  Reminder({
    required this.id,
    required this.title,
    this.notes,
    this.dueDate,
    TimeOfDay? dueTime,
    required this.type,
    this.location,
    required this.category,
    this.isCompleted = false,
    this.isFavorite = false,
  })  : dueHour = dueTime?.hour,
        dueMinute = dueTime?.minute;

  TimeOfDay? get dueTime =>
      (dueHour != null && dueMinute != null) ? TimeOfDay(hour: dueHour!, minute: dueMinute!) : null;
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
