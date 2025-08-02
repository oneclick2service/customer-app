import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isInitialized = false;
  StreamSubscription<RealtimeChannel>? _notificationSubscription;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      // Setup Supabase real-time notifications
      await _setupSupabaseNotifications();

      _isInitialized = true;
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestPermission();

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  // Setup Supabase real-time notifications
  Future<void> _setupSupabaseNotifications() async {
    try {
      // Subscribe to booking status changes
      _notificationSubscription = _supabase
          .channel('booking_notifications')
          .on(
            RealtimeListenTypes.postgresChanges,
            ChannelFilter(event: 'UPDATE', schema: 'public', table: 'bookings'),
            (payload, [ref]) {
              _handleBookingStatusChange(payload);
            },
          )
          .on(
            RealtimeListenTypes.postgresChanges,
            ChannelFilter(
              event: 'INSERT',
              schema: 'public',
              table: 'chat_messages',
            ),
            (payload, [ref]) {
              _handleNewChatMessage(payload);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error setting up Supabase notifications: $e');
    }
  }

  // Handle booking status changes
  void _handleBookingStatusChange(Map<String, dynamic> payload) {
    try {
      final newRecord = payload['new'] as Map<String, dynamic>?;
      final oldRecord = payload['old'] as Map<String, dynamic>?;

      if (newRecord == null) return;

      final bookingId = newRecord['id'] as String?;
      final status = newRecord['status'] as String?;
      final oldStatus = oldRecord?['status'] as String?;

      if (status != oldStatus && status != null) {
        _showBookingStatusNotification(bookingId!, status);
      }
    } catch (e) {
      debugPrint('Error handling booking status change: $e');
    }
  }

  // Handle new chat messages
  void _handleNewChatMessage(Map<String, dynamic> payload) {
    try {
      final newRecord = payload['new'] as Map<String, dynamic>?;
      if (newRecord == null) return;

      final senderId = newRecord['sender_id'] as String?;
      final message = newRecord['message'] as String?;
      final senderName = newRecord['sender_name'] as String?;

      // Don't show notification for user's own messages
      if (senderId == _supabase.auth.currentUser?.id) return;

      if (message != null && senderName != null) {
        _showChatNotification(senderName, message);
      }
    } catch (e) {
      debugPrint('Error handling new chat message: $e');
    }
  }

  // Show booking status notification
  Future<void> _showBookingStatusNotification(
    String bookingId,
    String status,
  ) async {
    String title = 'Booking Update';
    String body = '';

    switch (status.toLowerCase()) {
      case 'confirmed':
        body = 'Your booking has been confirmed!';
        break;
      case 'assigned':
        body = 'A service provider has been assigned to your booking.';
        break;
      case 'en_route':
        body = 'Your service provider is on the way!';
        break;
      case 'arrived':
        body = 'Your service provider has arrived.';
        break;
      case 'completed':
        body = 'Your service has been completed. Please rate your experience.';
        break;
      case 'cancelled':
        body = 'Your booking has been cancelled.';
        break;
      default:
        body = 'Your booking status has been updated.';
    }

    await _showNotification(
      id: bookingId.hashCode,
      title: title,
      body: body,
      payload: 'booking:$bookingId',
    );
  }

  // Show chat notification
  Future<void> _showChatNotification(String senderName, String message) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Message from $senderName',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      payload: 'chat',
    );
  }

  // Show local notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'oneclick2service_channel',
            'One Click 2 Service',
            channelDescription:
                'Notifications for service bookings and updates',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF2196F3), // App primary color
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    if (payload.startsWith('booking:')) {
      final bookingId = payload.substring(8);
      _navigateToBooking(bookingId);
    } else if (payload == 'chat') {
      _navigateToChat();
    }
  }

  // Navigate to booking details
  void _navigateToBooking(String bookingId) {
    // TODO: Navigate to booking details screen
    debugPrint('Navigate to booking: $bookingId');
  }

  // Navigate to chat
  void _navigateToChat() {
    // TODO: Navigate to chat screen
    debugPrint('Navigate to chat');
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error sending notification to user: $e');
    }
  }

  // Send booking status notification
  Future<void> sendBookingStatusNotification({
    required String userId,
    required String bookingId,
    required String status,
  }) async {
    String title = 'Booking Update';
    String body = '';

    switch (status.toLowerCase()) {
      case 'confirmed':
        body = 'Your booking has been confirmed!';
        break;
      case 'assigned':
        body = 'A service provider has been assigned to your booking.';
        break;
      case 'en_route':
        body = 'Your service provider is on the way!';
        break;
      case 'arrived':
        body = 'Your service provider has arrived.';
        break;
      case 'completed':
        body = 'Your service has been completed. Please rate your experience.';
        break;
      case 'cancelled':
        body = 'Your booking has been cancelled.';
        break;
      default:
        body = 'Your booking status has been updated.';
    }

    await sendNotificationToUser(
      userId: userId,
      title: title,
      body: body,
      payload: 'booking:$bookingId',
    );
  }

  // Send chat notification
  Future<void> sendChatNotification({
    required String userId,
    required String senderName,
    required String message,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Message from $senderName',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      payload: 'chat',
    );
  }

  // Get user's notification preferences
  Future<Map<String, dynamic>> getUserNotificationPreferences(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('user_preferences')
          .select('notification_settings')
          .eq('user_id', userId)
          .single();

      return response['notification_settings'] ?? {};
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
      return {};
    }
  }

  // Update user's notification preferences
  Future<void> updateUserNotificationPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _supabase.from('user_preferences').upsert({
        'user_id': userId,
        'notification_settings': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _notificationSubscription?.cancel();
  }
}
