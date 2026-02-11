import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialization settings for Android.
    // '@mipmap/ic_launcher' is the default app icon. If you have a custom notification
    // icon, place it in 'android/app/src/main/res/drawable' and change the name here.
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialization settings for iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showWelcomeNotification({String? username}) async {
    // Personalize the title if a username is provided
    final String title = username != null
        ? 'Welcome to AJ HUB, $username! 🎉'
        : 'Welcome to AJ HUB! 🎉';

    // Notification details for Android
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'welcome_channel', // A unique channel ID
      'Welcome Notifications', // A channel name
      channelDescription:
          'Channel for welcome notifications after registration',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Ensure this icon exists
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        'Thank you for joining our community. We are excited to have you on board! Explore the app now.',
        htmlFormatBigText: true,
        contentTitle: '<b>${title}</b>', // Use the dynamic title
        htmlFormatContentTitle: true,
      ),
    );

    // Notification details for iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show the notification
    await _notificationsPlugin.show(
      0, // Notification ID
      title, // Title
      'Thank you for joining our community. Explore the app now!', // Body
      notificationDetails,
    );
  }
}
