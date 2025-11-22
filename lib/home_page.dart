import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constant.dart';
import 'reminder_model.dart';
import 'reminder_card.dart';
import 'add_reminder_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Reminder> _reminders = dummyReminders;
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addReminder(Reminder newReminder) {
    setState(() {
      _reminders.add(newReminder);
    });
  }

  void _updateReminder(Reminder updatedReminder) {
    setState(() {
      int index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
      }
    });
  }

  void _deleteReminder(String id) {
    setState(() {
      _reminders.removeWhere((r) => r.id == id);
    });
  }

  List<Reminder> _getRemindersForTab(int tabIndex) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    List<Reminder> baseList;

    switch (tabIndex) {
      case 0: // Today
        baseList = _reminders.where((r) =>
            r.dueDate != null &&
            !r.isCompleted &&
            r.dueDate!.year == today.year &&
            r.dueDate!.month == today.month &&
            r.dueDate!.day == today.day).toList();
        break;
      case 1: // Upcoming
        baseList = _reminders.where((r) => r.dueDate != null && !r.isCompleted && r.dueDate!.isAfter(today)).toList()..sort((a,b)=> a.dueDate!.compareTo(b.dueDate!));
        break;
      case 2: // Location
        baseList = _reminders.where((r) => r.type == ReminderType.location && !r.isCompleted).toList();
        break;
      case 3: // Favorites
        baseList = _reminders.where((r) => r.isFavorite && !r.isCompleted).toList();
        break;
      case 4: // Completed
        baseList = _reminders.where((r) => r.isCompleted).toList();
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
              if (!_isSearching) {
                _searchController.clear();
              }
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
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[500],
                    ),
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
            MaterialPageRoute(
              builder: (context) => const AddReminderPage(),
            ),
          );
          if (newReminder != null) {
            _addReminder(newReminder);
          }
        },
        backgroundColor: AppConstant.PRIMARY_COLOR,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Reminder', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}