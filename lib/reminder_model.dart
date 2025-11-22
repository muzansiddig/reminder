import 'package:flutter/material.dart';

enum ReminderType { time, location }
enum ReminderCategory { work, personal, shopping, health }

class Reminder {
  final String id;
  String title;
  String? notes;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  ReminderType type;
  String? location;
  ReminderCategory category;
  bool isCompleted;
  bool isFavorite;

  Reminder({
    required this.id,
    required this.title,
    this.notes,
    this.dueDate,
    this.dueTime,
    required this.type,
    this.location,
    required this.category,
    this.isCompleted = false,
    this.isFavorite = false,
  });
}

// Dummy Data
List<Reminder> dummyReminders = [
  Reminder(
    id: '1',
    title: 'Team Meeting',
    notes: 'Discuss Q3 project goals.',
    dueDate: DateTime.now(),
    dueTime: const TimeOfDay(hour: 10, minute: 0),
    type: ReminderType.time,
    category: ReminderCategory.work,
  ),
  Reminder(
    id: '2',
    title: 'Buy Groceries',
    notes: 'Milk, bread, eggs, and cheese.',
    type: ReminderType.location,
    location: 'Supermarket',
    category: ReminderCategory.shopping,
    isFavorite: true
  ),
  Reminder(
    id: '3',
    title: 'Dentist Appointment',
    dueDate: DateTime.now().add(const Duration(days: 2)),
    dueTime: const TimeOfDay(hour: 14, minute: 30),
    type: ReminderType.time,
    category: ReminderCategory.health,
  ),
  Reminder(
    id: '4',
    title: 'Call Mom',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    dueTime: const TimeOfDay(hour: 19, minute: 0),
    type: ReminderType.time,
    category: ReminderCategory.personal,
  ),
   Reminder(
    id: '5',
    title: 'Finish Flutter Project',
    dueDate: DateTime.now().add(const Duration(days: 5)),
    dueTime: const TimeOfDay(hour: 23, minute: 59),
    type: ReminderType.time,
    category: ReminderCategory.work,
    isFavorite: true,
  ),
  Reminder(
    id: '6',
    title: 'Pay electricity bill',
    dueDate: DateTime.now(),
    dueTime: const TimeOfDay(hour: 12, minute: 0),
    type: ReminderType.time,
    category: ReminderCategory.personal,
    isCompleted: true,
  ),
  Reminder(
    id: '7',
    title: 'Pick up dry cleaning',
    type: ReminderType.location,
    location: 'Sunshine Cleaners',
    category: ReminderCategory.personal,
    isCompleted: true,
  ),
];

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}