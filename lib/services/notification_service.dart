import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;
  
  // Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize timezone data
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    _initialized = true;
    print('Notification service initialized');
  }
  
  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }
  
  // Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();
    
    // Request Android 13+ permissions
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    
    // Request iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return true;
  }
  
  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationImportance importance = NotificationImportance.high,
  }) async {
    if (!_initialized) await initialize();
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Notifications',
      channelDescription: 'Notifications for emergency alerts',
      importance: _mapImportance(importance),
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // Show emergency alert notification
  Future<void> showEmergencyAlert({
    required String emergencyType,
    required String message,
    String? location,
  }) async {
    await showNotification(
      id: 1,
      title: '🚨 EMERGENCY: $emergencyType',
      body: '$message${location != null ? '\nLocation: $location' : ''}',
      payload: 'emergency_alert',
      importance: NotificationImportance.max,
    );
  }
  
  // Show SOS triggered notification
  Future<void> showSOSTriggered({
    required int countdown,
  }) async {
    await showNotification(
      id: 2,
      title: '🚨 SOS TRIGGERED',
      body: 'Emergency services will be notified in $countdown seconds.\nTap to cancel.',
      payload: 'sos_triggered',
      importance: NotificationImportance.max,
    );
  }
  
  // Show accident detected notification
  Future<void> showAccidentDetected({
    required int countdown,
  }) async {
    await showNotification(
      id: 3,
      title: '⚠️ POSSIBLE ACCIDENT DETECTED',
      body: 'Emergency alert will be sent in $countdown seconds.\nTap "I\'m Safe" to cancel.',
      payload: 'accident_detected',
      importance: NotificationImportance.max,
    );
  }
  
  // Show weather alert notification
  Future<void> showWeatherAlert({
    required String alertType,
    required String description,
  }) async {
    await showNotification(
      id: 4,
      title: '🌧️ Weather Alert: $alertType',
      body: description,
      payload: 'weather_alert',
      importance: NotificationImportance.high,
    );
  }
  
  // Show contact notification sent
  Future<void> showContactsNotified({
    required int contactCount,
  }) async {
    await showNotification(
      id: 5,
      title: '✓ Emergency Contacts Notified',
      body: '$contactCount emergency contact(s) have been notified of your situation.',
      payload: 'contacts_notified',
      importance: NotificationImportance.high,
    );
  }
  
  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_initialized) await initialize();
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  // Show progress notification
  Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    if (!_initialized) await initialize();
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      channelDescription: 'Shows progress of operations',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      ongoing: true,
      autoCancel: false,
    );
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    
    await _notifications.show(
      id,
      title,
      body,
      details,
    );
  }
  
  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // Show persistent notification (for foreground service)
  Future<void> showPersistentNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'persistent_channel',
      'Persistent Notifications',
      channelDescription: 'Ongoing emergency monitoring',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    
    await _notifications.show(
      999,
      title,
      body,
      details,
    );
  }
  
  // Remove persistent notification
  Future<void> removePersistentNotification() async {
    await cancelNotification(999);
  }
  
  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  // Get active notifications (Android only)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      return await androidPlugin.getActiveNotifications();
    }
    
    return [];
  }
  
  // Map importance enum to Android Importance
  Importance _mapImportance(NotificationImportance importance) {
    switch (importance) {
      case NotificationImportance.min:
        return Importance.min;
      case NotificationImportance.low:
        return Importance.low;
      case NotificationImportance.normal:
        return Importance.defaultImportance;
      case NotificationImportance.high:
        return Importance.high;
      case NotificationImportance.max:
        return Importance.max;
    }
  }
}

// Custom importance enum
enum NotificationImportance {
  min,
  low,
  normal,
  high,
  max,
}