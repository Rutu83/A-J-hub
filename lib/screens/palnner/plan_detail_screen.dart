import 'dart:convert';

import 'package:ajhub_app/model/plan_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const Color kPrimaryColor = Color(0xFFE53935);

class PlanDetailScreen extends StatefulWidget {
  final UserPlan plan;
  const PlanDetailScreen({super.key, required this.plan});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: Text(
            'Are you sure you want to permanently delete "${widget.plan.title}"?'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() {
      _isDeleting = true;
    });

    try {
      final bool wasDeletedSuccessfully = await deletePlan(widget.plan.id);
      if (mounted) {
        if (wasDeletedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('"${widget.plan.title}" deleted.'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to delete plan.'),
              backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 40, thickness: 1),
            _buildGeneralDetails(),
            _buildCategorySpecificDetails(),
            if (widget.plan.notes != null && widget.plan.notes!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.notes_outlined,
                title: 'Notes / Agenda',
                content: widget.plan.notes!,
                isMultiLine: true,
              ),
            const SizedBox(height: 40),
            _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  // --- UPDATED WIDGET WITH TIMEZONE FIX ---
  Widget _buildGeneralDetails() {
    String formattedTime = widget.plan.eventTime ?? '';
    if (formattedTime.isNotEmpty) {
      try {
        final parsedTime = DateFormat('HH:mm:ss').parse(formattedTime);
        formattedTime = DateFormat('hh:mm a').format(parsedTime);
      } on FormatException {
        // Time is okay as is.
      }
    }

    String getFormattedDate(String? dateString) {
      // Return an empty string or a default message if the input is null or empty
      if (dateString == null || dateString.isEmpty) {
        return '';
      }

      try {
        // 1. Parse the date string.
        // This creates a DateTime object representing midnight UTC (e.g., 2025-08-13 00:00:00Z).
        final utcDate = DateTime.parse(dateString);

        // 2. THE FIX: Create a new DateTime object using the year, month, and day
        // from the parsed date. This constructor creates the date in the phone's
        // LOCAL timezone, effectively ignoring the time and timezone conversion.
        final localDate = DateTime(utcDate.year, utcDate.month, utcDate.day);

        // 3. Format the now-correct local date for display.
        return DateFormat('dd MMMM yyyy')
            .format(localDate); // Example: "13 August 2025"
        // Or use another format if you prefer:
        // return DateFormat('EEEE, MMMM dd, yyyy').format(localDate); // Example: "Wednesday, August 13, 2025"
      } catch (e) {
        // If the date string has an invalid format, return an empty string.
        print('Error parsing date: $e');
        return '';
      }
    }

    return Column(
      children: [
        if (widget.plan.category == 'DAY_MOVEMENT')
          _buildDayMovementFrequencyRow()
        else if (widget.plan.eventDate != null)
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            title: widget.plan.category == 'CELEBRATION'
                ? 'Date (Repeats Annually)'
                : 'Date',
            // Use the new helper function here
            content: getFormattedDate(widget.plan.eventDate),
          ),

        // Time Row (Only show for non-health reminders, as health has its own schedule)
        if (widget.plan.category != 'HEALTH_REMINDER' &&
            widget.plan.category != 'CELEBRATION')
          _buildDetailRow(
            icon: Icons.access_time_outlined,
            title: 'Time',
            content: formattedTime,
          ),

        // Reminder Row (Only show for non-health reminders)
        if (widget.plan.category != 'HEALTH_REMINDER')
          _buildDetailRow(
            icon: Icons.notifications_active_outlined,
            title: 'Reminder',
            content: widget.plan.reminderSetting.replaceAll('_', ' '),
          ),
      ],
    );
  }

  Widget _buildDayMovementFrequencyRow() {
    if (widget.plan.reminderSchedule == null ||
        widget.plan.reminderSchedule!.isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final List<dynamic> weekdays = jsonDecode(widget.plan.reminderSchedule!);
      if (weekdays.isEmpty) return const SizedBox.shrink();

      final String formattedDays =
          weekdays.map((day) => (day as String).capitalize()).join(', ');

      return _buildDetailRow(
        icon: Icons.repeat_on_outlined,
        title: 'Repeats Weekly On',
        content: formattedDays,
        isMultiLine: true,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          child: Icon(_getIconForCategory(widget.plan.category),
              size: 30, color: kPrimaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.plan.title,
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                widget.plan.category.replaceAll('_', ' '),
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
      {required IconData icon,
      required String title,
      required String content,
      Widget? trailing,
      bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(content,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildCategorySpecificDetails() {
    final plan = widget.plan;

    if (plan.category == 'MONTH_SCHEDULE' && plan.linkOrLocation != null) {
      try {
        final details = jsonDecode(plan.linkOrLocation!);
        if (details['type'] == 'PHYSICAL') {
          return _buildDetailRow(
              icon: Icons.location_on_outlined,
              title: 'Location',
              content: details['address'] ?? 'No address provided');
        } else if (details['type'] == 'ONLINE_MEETING') {
          Widget buildMeetingDetail(String key, String title, IconData icon) {
            if (details[key] != null && (details[key] as String).isNotEmpty) {
              return _buildDetailRow(
                  icon: icon,
                  title: title,
                  content: details[key],
                  trailing: _buildCopyButton(details[key]));
            }
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              _buildDetailRow(
                  icon: Icons.people_alt_outlined,
                  title: 'Platform',
                  content:
                      (details['platform'] as String).replaceAll('_', ' ') ??
                          'Online'),
              buildMeetingDetail('link', 'Meeting Link', Icons.link),
              buildMeetingDetail('zoom_id', 'Zoom ID', Icons.tag),
              buildMeetingDetail('password', 'Password', Icons.lock_outline),
            ],
          );
        }
      } catch (e) {
        return _buildDetailRow(
            icon: Icons.info_outline,
            title: 'Details',
            content: 'Not available');
      }
    } else if (plan.category == 'HEALTH_REMINDER') {
      // Logic for Health Reminders
      return Column(
        children: [
          // Shows the reminder rule, e.g., "On Schedule" or "Every 2 hours"
          if (plan.reminderSetting.isNotEmpty)
            _buildDetailRow(
              icon: Icons.notifications_active_outlined,
              title: 'Reminder Rule',
              content: plan.reminderSetting.replaceAll('_', ' ').capitalize(),
            ),

          // Shows the specific times based on the rule
          if (plan.reminderSchedule != null) _buildHealthScheduleDetails(),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  // --- UPDATED WIDGET WITH MEDICINE MAP FIX ---
  Widget _buildHealthScheduleDetails() {
    try {
      final scheduleData = jsonDecode(widget.plan.reminderSchedule!);

      if (widget.plan.category == 'HEALTH_REMINDER') {
        // Helper function to format names like "BEFORE_LUNCH" to "Before Lunch"
        String formatScheduleName(String name) {
          return name.split('_').map((word) => word.capitalize()).join(' ');
        }

        // NEW LOGIC: Handle the case where scheduleData is a Map {"BREAKFAST":"08:00:00", ...}
        if (scheduleData is Map) {
          if (scheduleData.isEmpty) return const SizedBox.shrink();

          final scheduleMap = scheduleData.cast<String, String>();

          final scheduleItems = scheduleMap.entries.map((entry) {
            final String key = entry.key;
            final String timeValue = entry.value;

            final String displayName = formatScheduleName(key);
            String formattedTime = '';

            try {
              // Parse HH:mm:ss and format to hh:mm a
              final parsedTime = DateFormat('HH:mm:ss').parse(timeValue);
              formattedTime = DateFormat('hh:mm a').format(parsedTime);
            } catch (e) {
              // If parsing fails, just use the raw value
              formattedTime = timeValue;
            }

            return '$displayName ($formattedTime)';
          }).join('\n');

          return _buildDetailRow(
            icon: Icons.checklist_rtl_outlined,
            title: 'Intake Schedule',
            content: scheduleItems,
            isMultiLine: true,
          );
        }
        // FALLBACK/LEGACY LOGIC: Handle the original case where scheduleData is a List ["BREAKFAST", ...]
        else if (scheduleData is List) {
          if (scheduleData.isEmpty) return const SizedBox.shrink();

          const Map<String, String> medicineTimes = {
            'BREAKFAST': '08:00 AM',
            'BEFORE_LUNCH': '12:30 PM',
            'AFTER_LUNCH': '02:00 PM',
            'BEFORE_DINNER': '06:30 PM',
            'AFTER_DINNER': '08:00 PM',
            'BEFORE_SLEEP': '10:00 PM',
          };

          String scheduleText = scheduleData.map((s) {
            final scheduleName = s.toString();
            final displayName = formatScheduleName(scheduleName);
            final time = medicineTimes[scheduleName] ?? '';
            return '$displayName${time.isNotEmpty ? " (around $time)" : ""}'
                .trim();
          }).join('\n');

          return _buildDetailRow(
              icon: Icons.checklist_rtl_outlined,
              title: 'Intake Schedule',
              content: scheduleText,
              isMultiLine: true);
        }
      } else if (widget.plan.subCategory == 'WATER' && scheduleData is Map) {
        final startTime = DateFormat('hh:mm a')
            .format(DateFormat('HH:mm:ss').parse(scheduleData['start_time']));
        final endTime = DateFormat('hh:mm a')
            .format(DateFormat('HH:mm:ss').parse(scheduleData['end_time']));

        final reminderTimes = _generateWaterReminderTimes(
            startTimeString: scheduleData['start_time'],
            endTimeString: scheduleData['end_time'],
            intervalMinutes: scheduleData['interval_minutes'] as int);

        String fullScheduleList = '';
        if (reminderTimes.isNotEmpty) {
          fullScheduleList = 'Times: ${reminderTimes.join(', ')}';
        }

        return _buildDetailRow(
            icon: Icons.timer_outlined,
            title: 'Time Window',
            content: 'From $startTime to $endTime\n$fullScheduleList'.trim(),
            isMultiLine: true);
      }
    } catch (e) {
      return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  List<String> _generateWaterReminderTimes({
    required String startTimeString,
    required String endTimeString,
    required int intervalMinutes,
  }) {
    final List<String> times = [];
    if (intervalMinutes <= 0) return times;

    try {
      DateTime startTime = DateFormat('HH:mm:ss').parse(startTimeString);
      DateTime endTime = DateFormat('HH:mm:ss').parse(endTimeString);

      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }

      DateTime currentTime = startTime;
      while (currentTime.isBefore(endTime) ||
          currentTime.isAtSameMomentAs(endTime)) {
        times.add(DateFormat('hh:mm a').format(currentTime));
        currentTime = currentTime.add(Duration(minutes: intervalMinutes));
      }
    } catch (e) {
      return [];
    }
    return times;
  }

  Widget _buildCopyButton(String textToCopy) {
    return IconButton(
      splashRadius: 20,
      icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: textToCopy));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Copied to clipboard!'),
            duration: Duration(seconds: 1)));
      },
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _isDeleting
            ? Container()
            : const Icon(Icons.delete_outline, color: Colors.white),
        label: _isDeleting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : const Text('DELETE PLAN',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: _isDeleting ? null : _handleDelete,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'DAY_MOVEMENT':
        return Icons.wb_sunny_outlined;
      case 'MONTH_SCHEDULE':
        return Icons.edit_calendar_outlined;
      case 'CELEBRATION':
        return Icons.cake_outlined;
      case 'HEALTH_REMINDER':
        return Icons.medical_services_outlined;
      default:
        return Icons.rule;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
