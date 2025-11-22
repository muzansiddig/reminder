import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'app_constant.dart';
import 'reminder_model.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final Function(Reminder) onChanged;
  final Function(String) onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onChanged,
    required this.onDelete,
  });

  String _formatDateTime(BuildContext context) {
    if (reminder.dueDate == null) return "No date";
    String date = DateFormat.yMMMd().format(reminder.dueDate!);
    String time = reminder.dueTime?.format(context) ?? "";
    return '$date $time'.trim();
  }

  IconData _getCategoryIcon(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.work:
        return Icons.work;
      case ReminderCategory.personal:
        return Icons.person;
      case ReminderCategory.shopping:
        return Icons.shopping_cart;
      case ReminderCategory.health:
        return Icons.favorite;
    }
  }

  Color _getCategoryColor(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.work:
        return Colors.blue;
      case ReminderCategory.personal:
        return Colors.green;
      case ReminderCategory.shopping:
        return Colors.orange;
      case ReminderCategory.health:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = reminder.dueDate != null && reminder.dueDate!.isBefore(DateTime.now()) && !reminder.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstant.PADDING_MEDIUM),
      elevation: AppConstant.ELEVATION,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
      ),
      child: Material(
        color: reminder.isCompleted ? Colors.grey[200] : AppConstant.SURFACE_COLOR,
        borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
        child: InkWell(
          onLongPress: () {
             showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Reminder'),
                    content: const Text('Are you sure you want to delete this reminder?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Delete', style: TextStyle(color: AppConstant.ERROR_COLOR)),
                        onPressed: () {
                          onDelete(reminder.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstant.PADDING_SMALL, horizontal: AppConstant.PADDING_MEDIUM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: reminder.isCompleted,
                  onChanged: (bool? value) {
                    reminder.isCompleted = value ?? false;
                    onChanged(reminder);
                  },
                  activeColor: AppConstant.PRIMARY_COLOR,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: GoogleFonts.poppins(
                          fontSize: AppConstant.FONT_SUBTITLE,
                          fontWeight: FontWeight.w600,
                          color: reminder.isCompleted ? AppConstant.COMPLETED_COLOR : AppConstant.TEXT_PRIMARY,
                          decoration: reminder.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            reminder.type == ReminderType.time ? Icons.timer_outlined : Icons.location_on_outlined,
                            size: 16,
                            color: isExpired ? AppConstant.ERROR_COLOR : AppConstant.TEXT_SECONDARY,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reminder.type == ReminderType.time ? _formatDateTime(context) : reminder.location ?? "No location",
                            style: GoogleFonts.poppins(
                              fontSize: AppConstant.FONT_BODY,
                              color: isExpired ? AppConstant.ERROR_COLOR : AppConstant.TEXT_SECONDARY,
                            ),
                          ),
                        ],
                      ),
                      if(reminder.notes != null && reminder.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            reminder.notes!,
                            style: GoogleFonts.poppins(
                              fontSize: AppConstant.FONT_CAPTION,
                              color: AppConstant.TEXT_SECONDARY,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Chip(
                          avatar: Icon(_getCategoryIcon(reminder.category), color: Colors.white, size: 16),
                          label: Text(reminder.category.name.capitalize()),
                          backgroundColor: _getCategoryColor(reminder.category),
                          labelStyle: GoogleFonts.poppins(fontSize: AppConstant.FONT_CAPTION, color: Colors.white, fontWeight: FontWeight.w500),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    reminder.isFavorite ? Icons.star : Icons.star_border,
                    color: AppConstant.FAVORITE_COLOR,
                  ),
                  onPressed: () {
                    reminder.isFavorite = !reminder.isFavorite;
                    onChanged(reminder);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}