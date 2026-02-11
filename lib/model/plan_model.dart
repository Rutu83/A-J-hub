// lib/model/plan_model.dart

import 'dart:convert';

// Helper function to decode the main JSON string which is an array
List<UserPlan> userPlanFromJson(String str) =>
    List<UserPlan>.from(json.decode(str).map((x) => UserPlan.fromJson(x)));

class UserPlan {
  final int id;
  final int userId;
  final String category;
  final String? subCategory;
  final String title;
  final String? eventDate;
  final String? eventTime;
  final String? linkOrLocation;
  final String? notes;
  final String reminderSetting;
  final String? reminderSchedule;
  final bool isRecurring;
  bool isCompleted; // Mutable to update UI instantly

  UserPlan({
    required this.id,
    required this.userId,
    required this.category,
    this.subCategory,
    required this.title,
    this.eventDate,
    this.eventTime,
    this.linkOrLocation,
    this.notes,
    required this.reminderSetting,
    this.reminderSchedule,
    required this.isRecurring,
    required this.isCompleted,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) => UserPlan(
        id: json["id"],
        userId: json["user_id"],
        category: json["category"],
        subCategory: json["sub_category"],
        title: json["title"],
        eventDate: json["event_date"],
        // Format time for display if it exists
        eventTime: json["event_time"] != null
            ? _formatDisplayTime(json["event_time"])
            : null,
        linkOrLocation: json["link_or_location"],
        notes: json["notes"],
        reminderSetting: json["reminder_setting"],
        reminderSchedule: json["reminder_schedule"],
        isRecurring: json["is_recurring"] == 1,
        isCompleted: json["is_completed"] == 1,
      );

  // Helper to format "14:30:00" into "02:30 PM"
  static String? _formatDisplayTime(String timeString) {
    try {
      final hour = int.parse(timeString.substring(0, 2));
      final minute = timeString.substring(3, 5);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return timeString; // Fallback to original string on error
    }
  }
}
