import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_constant.dart';
import 'reminder_model.dart';
import 'reminder_card.dart';
import 'add_reminder_page.dart';
import 'main.dart'; // notificationsPlugin
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late Box<Reminder> _reminderBox;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _reminderBox = Hive.box<Reminder>('remindersBox');
  }

  void _addReminder(Reminder newReminder) async {
    if (newReminder.id.isEmpty) {
      newReminder.id = DateTime.now().millisecondsSinceEpoch.toString();
    }
    await _reminderBox.add(newReminder);
    _scheduleNotification(newReminder);
  }

  void _updateReminder(Reminder updatedReminder) async {
    final index = _reminderBox.values.toList().indexWhere((r) => r.id == updatedReminder.id);
    if (index != -1) {
      await _reminderBox.putAt(index, updatedReminder);
      _scheduleNotification(updatedReminder);
    }
  }

  void _deleteReminder(String id) async {
    final index = _reminderBox.values.toList().indexWhere((r) => r.id == id);
    if (index != -1) {
      await notificationsPlugin.cancel(int.parse(id));
      await _reminderBox.deleteAt(index);
    }
  }

  void _scheduleNotification(Reminder reminder) async {
    if (reminder.dueDate == null) return;

    DateTime scheduledTime = reminder.dueDate!;
    if (reminder.dueHour != null && reminder.dueMinute != null) {
      scheduledTime = DateTime(
        reminder.dueDate!.year,
        reminder.dueDate!.month,
        reminder.dueDate!.day,
        reminder.dueHour!,
        reminder.dueMinute!,
      );
    }

    if (scheduledTime.isAfter(DateTime.now())) {
      await notificationsPlugin.zonedSchedule(
        int.parse(reminder.id),
        reminder.title,
        reminder.notes ?? '',
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminders',
            channelDescription: 'Channel for reminder notifications',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  List<Reminder> _getRemindersForTab(int tabIndex) {
    final reminders = _reminderBox.values.toList();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    List<Reminder> baseList;

    switch (tabIndex) {
      case 0:
        baseList = reminders.where((r) =>
            r.dueDate != null &&
            !r.isCompleted &&
            r.dueDate!.year == today.year &&
            r.dueDate!.month == today.month &&
            r.dueDate!.day == today.day).toList();
        break;
      case 1:
        baseList = reminders.where((r) =>
            r.dueDate != null && !r.isCompleted && r.dueDate!.isAfter(today)).toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
        break;
      case 2:
        baseList = reminders.where((r) => r.type == ReminderType.location && !r.isCompleted).toList();
        break;
      case 3:
        baseList = reminders.where((r) => r.isFavorite && !r.isCompleted).toList();
        break;
      case 4:
        baseList = reminders.where((r) => r.isCompleted).toList();
        break;
      default:
        baseList = [];
    }

    if (_searchQuery.isNotEmpty) {
      return baseList.where((reminder) {
        final titleMatch = reminder.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final notesMatch = reminder.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        return titleMatch || notesMatch;
      }).toList();
    }

    return baseList;
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search reminders...',
                border: InputBorder.none,
                hintStyle: GoogleFonts.poppins(color: AppConstant.TEXT_SECONDARY),
              ),
              style: GoogleFonts.poppins(color: AppConstant.TEXT_PRIMARY),
            )
          : Text(
              AppConstant.APP_NAME,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppConstant.TEXT_PRIMARY,
              ),
            ),
      elevation: 0,
      backgroundColor: AppConstant.BACKGROUND_COLOR,
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppConstant.TEXT_SECONDARY),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            });
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppConstant.PRIMARY_COLOR,
        labelColor: AppConstant.PRIMARY_COLOR,
        unselectedLabelColor: AppConstant.TEXT_SECONDARY,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        tabs: const [
          Tab(icon: Icon(Icons.today), text: 'Today'),
          Tab(icon: Icon(Icons.calendar_month), text: 'Upcoming'),
          Tab(icon: Icon(Icons.location_on), text: 'Location'),
          Tab(icon: Icon(Icons.star), text: 'Favorites'),
          Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _reminderBox.listenable(),
      builder: (context, Box<Reminder> box, _) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: TabBarView(
            controller: _tabController,
            children: List.generate(5, (index) {
              final remindersForTab = _getRemindersForTab(index);
              if (remindersForTab.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty ? 'No reminders found' : 'No reminders here!',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
                itemCount: remindersForTab.length,
                itemBuilder: (context, i) {
                  return ReminderCard(
                    reminder: remindersForTab[i],
                    onChanged: _updateReminder,
                    onDelete: _deleteReminder,
                  );
                },
              );
            }),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final newReminder = await Navigator.push<Reminder>(
                context,
                MaterialPageRoute(builder: (_) => const AddReminderPage()),
              );
              if (newReminder != null) _addReminder(newReminder);
            },
            backgroundColor: AppConstant.PRIMARY_COLOR,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Add Reminder',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        );
      },
    );
  }
}
