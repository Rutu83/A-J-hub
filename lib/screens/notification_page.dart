import 'package:ajhub_app/network/notification_service.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the new service and model

// A helper class to map notification types to UI elements
class NotificationDetails {
  final IconData icon;
  final Color color;
  NotificationDetails(this.icon, this.color);
}

// --- Main Notification Page Widget ---
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Use a Future to hold the API call state
  late Future<List<NotificationModel>> _notificationsFuture;
  List<NotificationModel> _notifications = []; // Local cache of notifications

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Function to load or reload notifications from the API
  void _loadNotifications() {
    _notificationsFuture = fetchNotification();
    // Update the local cache when the future completes successfully
    _notificationsFuture.then((data) {
      if (mounted) {
        setState(() {
          _notifications = data;
        });
      }
    });
  }

  // Helper function to map notification_type from API to an icon and color
  NotificationDetails _getNotificationDetails(String type) {
    switch (type) {
      case 'alert':
        return NotificationDetails(Icons.new_releases, Colors.orange.shade700);
      case 'promo':
        return NotificationDetails(Icons.campaign, Colors.blue.shade600);
      case 'social':
        return NotificationDetails(Icons.person_add, Colors.green.shade600);
      case 'update':
        return NotificationDetails(Icons.system_update, Colors.grey.shade700);
      default: // 'general' or any other type
        return NotificationDetails(Icons.notifications, Colors.purple.shade500);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      setState(() {
        for (var notification in _notifications) {
          notification = notification.copyWith(
              isRead: true); // Update local state immediately
        }
        _loadNotifications(); // Reload from server to be sure
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('All notifications marked as read.'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    // Avoid re-marking if already read
    if (notification.isRead) return;

    try {
      await NotificationService.markAsRead(notification.id);
      setState(() {
        // Find the notification in the local list and update its read status
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    } catch (e) {
      print("Failed to mark as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Use the local list to determine if the button should be shown
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      // Use FutureBuilder to handle loading/error/success states
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // On success, use the local _notifications list which is kept in sync
          return RefreshIndicator(
            onRefresh: () async => _loadNotifications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12.0),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final details = _getNotificationDetails(notification.notificationType);

    return GestureDetector(
      onTap: () => _markAsRead(notification),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        color: notification.isRead ? Colors.white : const Color(0xFFFFFBEB),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: details.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(details.icon, color: details.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification
                          .createdAgo, // Using the user-friendly time from API
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // Your _buildEmptyState widget code remains the same...
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80, color: Colors.grey[400]),
          SizedBox(height: 20.h),
          Text('No Notifications Yet',
              style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          SizedBox(height: 10.h),
          Text("You'll see important updates and offers here.",
              style:
                  GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// Add this extension to your NotificationModel to easily update its properties
extension NotificationModelCopyWith on NotificationModel {
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      notificationType: notificationType,
      createdAt: createdAt,
      createdAgo: createdAgo,
    );
  }
}
