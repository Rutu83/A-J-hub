import 'dart:convert';

import 'package:ajhub_app/model/plan_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/palnner/add_plan_screen.dart';
import 'package:ajhub_app/screens/palnner/plan_detail_screen.dart';
import 'package:ajhub_app/utils/shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

const Color kPrimaryColor = Color(0xFFE53935);

enum PlanViewType { Agenda, Daily, Monthly }

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({super.key});

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {
  late Future<List<UserPlan>> _plansFuture;
  DateTime _filterDate = DateTime.now();
  PlanViewType _currentView = PlanViewType.Agenda;

  final Map<String, TimeOfDay> _medicineScheduleTimes = {
    'BEFORE_BREAKFAST': const TimeOfDay(hour: 8, minute: 0),
    'AFTER_BREAKFAST': const TimeOfDay(hour: 9, minute: 0),
    'BEFORE_LUNCH': const TimeOfDay(hour: 12, minute: 30),
    'AFTER_LUNCH': const TimeOfDay(hour: 13, minute: 30),
    'BEFORE_DINNER': const TimeOfDay(hour: 19, minute: 0),
    'AFTER_DINNER': const TimeOfDay(hour: 20, minute: 0),
    'BEFORE_SLEEP': const TimeOfDay(hour: 22, minute: 0),
  };

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _rescheduleAllNotifications();
  }

  // <<< FIX START: New helper function to correctly parse date strings.
  /// Parses a date string (e.g., "2025-08-13") into a correct local DateTime object.
  /// This prevents the "previous day" timezone bug.
  DateTime? _parseDateStringAsLocal(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    // Step 1: Parse the string. We now have the date for MIDNIGHT UTC.
    // Example: utcDate represents August 13th, 12:00 AM in London.
    final utcDate = DateTime.parse(dateString);

    // Step 2: THIS IS THE FIX.
    // We take ONLY the numbers for the date (2025, 8, 13).
    // We throw away the time (midnight) and the timezone (UTC).
    // Then, we create a BRAND NEW DateTime object that is set to
    // midnight in the PHONE'S LOCAL TIMEZONE.
    // This correctly anchors the date to the user's day.
    return DateTime(utcDate.year, utcDate.month, utcDate.day);
  }
  // <<< FIX END

  void _fetchPlans() {
    print("Fetching plans with view: $_currentView, date: $_filterDate");

    setState(() {
      switch (_currentView) {
        case PlanViewType.Agenda:
          _plansFuture = getPlans();
          break;
        case PlanViewType.Daily:
          _plansFuture =
              getPlans(date: DateFormat('yyyy-MM-dd').format(_filterDate));
          break;
        case PlanViewType.Monthly:
          _plansFuture =
              getPlans(month: DateFormat('yyyy-MM').format(_filterDate));
          break;
      }
    });
  }

  Future<void> _navigateToAddPlan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPlanScreen()),
    );
    if (mounted) {
      _fetchPlans();
      _rescheduleAllNotifications();
    }
  }

  Future<void> _selectDay(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: kPrimaryColor),
          buttonTheme:
              const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _filterDate = picked;
        _currentView = PlanViewType.Daily;
      });
      _fetchPlans();
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: _filterDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _filterDate = picked;
        _currentView = PlanViewType.Monthly;
      });
      _fetchPlans();
    }
  }

  Future<void> _deletePlan(UserPlan plan, List<UserPlan> currentList) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: Text('Are you sure you want to delete "${plan.title}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final int planIndex = currentList.indexOf(plan);
    setState(() {
      currentList.removeAt(planIndex);
    });

    try {
      await _cancelPlanNotifications(plan);
      final bool wasDeletedSuccessfully = await deletePlan(plan.id);
      if (mounted) {
        if (wasDeletedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('"${plan.title}" was deleted.'),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to delete plan. Please try again.'),
            backgroundColor: Colors.red,
          ));
          setState(() {
            currentList.insert(planIndex, plan);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          currentList.insert(planIndex, plan);
        });
      }
    }
  }

  Future<void> _rescheduleAllNotifications() async {
    try {
      List<UserPlan> allPlans = await getPlans();
      // await NotificationService().cancelAllNotifications();

      for (var plan in allPlans) {
        if (plan.isCompleted) continue;
        if (plan.category == 'HEALTH_REMINDER') {
          await _scheduleHealthNotification(plan);
        } else {
          await _scheduleStandardNotification(plan);
        }
      }
    } catch (e) {
      print("Error during notification re-scheduling: $e");
    }
  }

  Future<void> _scheduleStandardNotification(UserPlan plan) async {
    if (plan.eventDate == null || plan.eventTime == null) return;
    final reminderDateTime = _calculateReminderDateTime(
        plan.eventDate!, plan.eventTime!, plan.reminderSetting);
    if (reminderDateTime != null && reminderDateTime.isAfter(DateTime.now())) {
      // NotificationService().scheduleNotification( ... );
    }
  }

  Future<void> _scheduleHealthNotification(UserPlan plan) async {
    if (plan.reminderSchedule == null) return;
    try {
      final scheduleData = jsonDecode(plan.reminderSchedule!);
      if (plan.subCategory == 'MEDICINE' && scheduleData is List) {
        for (int i = 0; i < scheduleData.length; i++) {
          final scheduleKey = scheduleData[i];
          final time = _medicineScheduleTimes[scheduleKey];
          if (time != null) {
            // int notificationId = plan.id * 100 + i;
            // await NotificationService().scheduleDailyNotification( ... );
          }
        }
      } else if (plan.subCategory == 'WATER' && scheduleData is Map) {
        // ... Logic for water notifications ...
      }
    } catch (e) {
      print("Error scheduling health notification for plan ${plan.id}: $e");
    }
  }

  Future<void> _cancelPlanNotifications(UserPlan plan) async {
    if (plan.category == 'HEALTH_REMINDER') {
      for (int i = 0; i < 20; i++) {
        // await NotificationService().cancelNotification(plan.id * 100 + i);
        // await NotificationService().cancelNotification(plan.id * 200 + i);
      }
    } else {
      // await NotificationService().cancelNotification(plan.id);
    }
  }

  DateTime? _calculateReminderDateTime(
      String eventDateStr, String eventTimeStr, String reminderSetting) {
    try {
      // This parsing is usually safe as it combines date and time, creating a local time.
      final eventDateTime = DateTime.parse('$eventDateStr $eventTimeStr');
      Duration reminderOffset;
      switch (reminderSetting) {
        case '5 minutes before':
          reminderOffset = const Duration(minutes: 5);
          break;
        case '10 minutes before':
          reminderOffset = const Duration(minutes: 10);
          break;
        case '15 minutes before':
          reminderOffset = const Duration(minutes: 15);
          break;
        case '1 hour before':
          reminderOffset = const Duration(hours: 1);
          break;
        case '1 day before':
          reminderOffset = const Duration(days: 1);
          break;
        case '1 week before':
          reminderOffset = const Duration(days: 7);
          break;
        case 'On time':
        case 'At time of event':
        default:
          return eventDateTime;
      }
      return eventDateTime.subtract(reminderOffset);
    } catch (e) {
      print("Error parsing date/time for notification: $e");
      return null;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'DAY_MOVEMENT':
        return Icons.wb_sunny_outlined;
      case 'MONTH_SCHEDULE':
        return CupertinoIcons.calendar_today;
      case 'CELEBRATION':
        return CupertinoIcons.gift_alt;
      case 'HEALTH_REMINDER':
        return Icons.medical_services_outlined;
      default:
        return Icons.rule;
    }
  }

  String _getSubtitleForPlan(UserPlan plan) {
    if (plan.category == 'HEALTH_REMINDER') {
      if (plan.subCategory != null) {
        return "${PlannerStringExtension(plan.subCategory!).capitalize()} Reminder";
      }
      return "Health Reminder";
    }

    final List<String> subtitleParts = [];
    String dateTimeInfo = '';

    if (plan.eventDate != null) {
      // <<< FIX: Use the new helper function to parse the date correctly
      final localEventDate = _parseDateStringAsLocal(plan.eventDate);
      if (localEventDate != null) {
        dateTimeInfo = DateFormat('EEE, MMM d').format(localEventDate);
        if (plan.eventTime != null) {
          try {
            final time = DateFormat('hh:mm a').parse(plan.eventTime!);
            dateTimeInfo += ' • ${DateFormat('hh:mm a').format(time)}';
          } catch (e) {
            // Fallback if time parsing fails
            dateTimeInfo += ' • ${plan.eventTime!}';
          }
        }
      }
    } else if (plan.eventTime != null) {
      try {
        final time = DateFormat('hh:mm a').parse(plan.eventTime!);
        dateTimeInfo = DateFormat('hh:mm a').format(time);
      } catch (e) {
        dateTimeInfo = plan.eventTime!;
      }
    }

    if (dateTimeInfo.isNotEmpty) {
      subtitleParts.add(dateTimeInfo);
    }

    String detailsInfo = '';
    if (plan.category == 'MONTH_SCHEDULE' && plan.linkOrLocation != null) {
      try {
        final details = jsonDecode(plan.linkOrLocation!);
        if (details['type'] == 'PHYSICAL') {
          detailsInfo = details['address'];
        } else if (details['type'] == 'ONLINE_MEETING') {
          final platform = details['platform'] ?? 'Online';
          final zoomId =
              details['zoom_id'] != null ? ' (ID: ${details['zoom_id']})' : '';
          detailsInfo = "Online Meeting: $platform$zoomId";
        }
      } catch (e) {
        detailsInfo = plan.linkOrLocation!;
      }
    }

    if (detailsInfo.isNotEmpty) {
      subtitleParts.add(detailsInfo);
    }

    return subtitleParts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (_currentView) {
      case PlanViewType.Agenda:
        title = 'Agenda';
        break;
      case PlanViewType.Daily:
        title = 'Daily Plan';
        break;
      case PlanViewType.Monthly:
        title = 'Monthly Plan';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 1,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 20.0.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        actions: [
          IconButton(
            tooltip: 'Agenda View',
            icon: Icon(CupertinoIcons.list_bullet,
                color: _currentView == PlanViewType.Agenda
                    ? kPrimaryColor
                    : Colors.grey.shade700),
            onPressed: () {
              if (_currentView != PlanViewType.Agenda) {
                setState(() => _currentView = PlanViewType.Agenda);
                _fetchPlans();
              }
            },
          ),
          IconButton(
            tooltip: 'Daily View',
            icon: Icon(CupertinoIcons.calendar_today,
                color: _currentView == PlanViewType.Daily
                    ? kPrimaryColor
                    : Colors.grey.shade700),
            onPressed: () => _selectDay(context),
          ),
          IconButton(
            tooltip: 'Monthly View',
            icon: Icon(Icons.calendar_month,
                color: _currentView == PlanViewType.Monthly
                    ? kPrimaryColor
                    : Colors.grey.shade700),
            onPressed: () => _selectMonth(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_currentView == PlanViewType.Daily)
            // This is safe because _filterDate is already a local DateTime object
            _buildHeader(DateFormat('EEEE, MMMM dd, yyyy').format(_filterDate)),
          if (_currentView == PlanViewType.Monthly)
            _buildHeader(DateFormat('MMMM yyyy').format(_filterDate)),
          Expanded(
            child: FutureBuilder<List<UserPlan>>(
              future: _plansFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeletonLoader();
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }
                final plans = snapshot.data!;
                return _buildAgendaView(plans);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPlan,
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildAgendaView(List<UserPlan> plans) {
    final List<String> categoryOrder = [
      'DAY_MOVEMENT',
      'MONTH_SCHEDULE',
      'CELEBRATION',
      'HEALTH_REMINDER',
    ];

    final Map<String, List<UserPlan>> groupedPlans = {};
    for (var plan in plans) {
      if (groupedPlans[plan.category] == null) {
        groupedPlans[plan.category] = [];
      }
      groupedPlans[plan.category]!.add(plan);
    }

    groupedPlans.forEach((category, planList) {
      planList.sort((a, b) {
        if (a.eventDate == null) return 1;
        if (b.eventDate == null) return -1;
        try {
          // <<< FIX: Use the helper function here too for consistent sorting
          final dateA = _parseDateStringAsLocal(a.eventDate!);
          final dateB = _parseDateStringAsLocal(b.eventDate!);

          // Handle cases where parsing might fail
          if (dateA == null) return 1;
          if (dateB == null) return -1;

          int dateComparison = dateA.compareTo(dateB);
          if (dateComparison != 0) return dateComparison;

          if (a.eventTime == null) return -1;
          if (b.eventTime == null) return 1;

          final timeA = DateFormat('hh:mm a').parse(a.eventTime!);
          final timeB = DateFormat('hh:mm a').parse(b.eventTime!);
          return timeA.compareTo(timeB);
        } catch (e) {
          print("Error during plan sorting: $e");
          return 0;
        }
      });
    });

    List<Widget> listItems = [];
    for (String category in categoryOrder) {
      if (groupedPlans.containsKey(category)) {
        List<UserPlan> categoryPlans = groupedPlans[category]!;
        listItems.add(
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
            child: Text(
              _getDisplayTitleForCategory(category),
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
        );
        listItems
            .addAll(categoryPlans.map((plan) => _buildPlanCard(plan, plans)));
      }
    }

    if (listItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      children: listItems,
    );
  }

  String _getDisplayTitleForCategory(String category) {
    return category
        .replaceAll('_', ' ')
        .toUpperCase()
        .split(' ')
        .map((word) => word)
        .join(' ');
  }

  Widget _buildPlanCard(UserPlan plan, List<UserPlan> currentList) {
    String subtitle = _getSubtitleForPlan(plan);
    return Dismissible(
      key: Key(plan.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deletePlan(plan, currentList),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: kPrimaryColor, borderRadius: BorderRadius.circular(12)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(CupertinoIcons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PlanDetailScreen(plan: plan)),
            );
            if (mounted) _fetchPlans();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  child: Icon(_getIconForCategory(plan.category),
                      color: kPrimaryColor, size: 22),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: Colors.black87,
                          decoration: plan.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Colors.grey,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade600, fontSize: 13.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Checkbox(
                  value: plan.isCompleted,
                  activeColor: kPrimaryColor,
                  onChanged: (bool? value) async {
                    if (value != null) {
                      setState(() => plan.isCompleted = value);
                      await updatePlanStatus(plan.id, value);
                      if (value == true) {
                        await _cancelPlanNotifications(plan);
                      } else {
                        if (plan.category == 'HEALTH_REMINDER') {
                          await _scheduleHealthNotification(plan);
                        } else {
                          await _scheduleStandardNotification(plan);
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 6,
        itemBuilder: (_, __) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.white),
            title: Container(height: 16, color: Colors.white),
            subtitle: Container(height: 12, width: 100, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _currentView == PlanViewType.Agenda
                ? 'No upcoming plans'
                : 'No plans for this period',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text('Tap the + button to add one.',
              style: GoogleFonts.poppins(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 80),
            const SizedBox(height: 20),
            Text('Failed to Load Plans',
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(error,
                style: GoogleFonts.poppins(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchPlans,
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

extension PlannerStringExtension on String {
  String capitalize() {
    return (isEmpty) ? '' : "${this[0].toUpperCase()}${substring(1)}";
  }
}
