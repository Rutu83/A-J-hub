// --- Data Model to match the JSON from the Laravel API ---
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String notificationType;
  final DateTime createdAt;
  final String createdAgo;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.notificationType,
    required this.createdAt,
    required this.createdAgo,
  });

  // Factory constructor to create a NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'], // Laravel casts this to boolean
      notificationType: json['notification_type'],
      createdAt: DateTime.parse(json['created_at']),
      createdAgo: json['created_ago'],
    );
  }
}

class NotificationService {
  // IMPORTANT: Replace with your actual API base URL

  // Method to fetch notifications for the logged-in user

  // --- TODO: Implement these API calls in your Laravel backend ---

  // Placeholder function to mark a single notification as read
  static Future<void> markAsRead(int notificationId) async {
    print('API CALL: Mark notification $notificationId as read.');
    // final response = await http.post(Uri.parse('$_baseUrl/notifications/$notificationId/read'), ...);
    // if (response.statusCode != 200) throw Exception('Failed to mark as read');
  }

  // Placeholder function to mark all notifications as read
  static Future<void> markAllAsRead() async {
    print('API CALL: Mark all notifications as read.');
    // final response = await http.post(Uri.parse('$_baseUrl/notifications/mark-all-read'), ...);
    // if (response.statusCode != 200) throw Exception('Failed to mark all as read');
  }
}
