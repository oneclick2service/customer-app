import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import 'notification_service.dart';

class BookingStatusService {
  static final BookingStatusService _instance =
      BookingStatusService._internal();
  factory BookingStatusService() => _instance;
  BookingStatusService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();

  RealtimeChannel? _bookingStatusSubscription;
  final List<Function(BookingModel)> _statusUpdateListeners = [];

  // Booking status constants
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_CONFIRMED = 'confirmed';
  static const String STATUS_ASSIGNED = 'assigned';
  static const String STATUS_EN_ROUTE = 'en_route';
  static const String STATUS_ARRIVED = 'arrived';
  static const String STATUS_IN_PROGRESS = 'in_progress';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_CANCELLED = 'cancelled';

  // Initialize real-time booking status updates
  Future<void> initialize() async {
    await _setupBookingStatusSubscription();
  }

  // Setup real-time subscription for booking status changes
  Future<void> _setupBookingStatusSubscription() async {
    try {
      _bookingStatusSubscription = _supabase
          .channel('booking_status_updates')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'bookings',
            callback: (payload) {
              _handleBookingStatusUpdate(payload);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error setting up booking status subscription: $e');
    }
  }

  // Handle booking status updates from Supabase Realtime
  void _handleBookingStatusUpdate(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord as Map<String, dynamic>;
      final oldRecord = payload.oldRecord as Map<String, dynamic>;

      final oldStatus = oldRecord['status'] as String?;
      final newStatus = newRecord['status'] as String?;

      if (oldStatus != newStatus && newStatus != null) {
        final booking = BookingModel.fromJson(newRecord);

        // Notify all listeners
        for (final listener in _statusUpdateListeners) {
          listener(booking);
        }

        // Send notification
        _sendStatusUpdateNotification(booking, oldStatus, newStatus);
      }
    } catch (e) {
      debugPrint('Error handling booking status update: $e');
    }
  }

  // Send notification for status updates
  void _sendStatusUpdateNotification(
    BookingModel booking,
    String? oldStatus,
    String newStatus,
  ) {
    final user = _supabase.auth.currentUser;
    if (user == null || booking.customerId != user.id) return;

    String title = 'Booking Update';
    String body = '';

    switch (newStatus) {
      case STATUS_CONFIRMED:
        body = 'Your booking has been confirmed!';
        break;
      case STATUS_ASSIGNED:
        body = 'A service provider has been assigned to your booking.';
        break;
      case STATUS_EN_ROUTE:
        body = 'Your service provider is on the way!';
        break;
      case STATUS_ARRIVED:
        body = 'Your service provider has arrived!';
        break;
      case STATUS_IN_PROGRESS:
        body = 'Service is now in progress.';
        break;
      case STATUS_COMPLETED:
        body = 'Service has been completed! Please rate your experience.';
        break;
      case STATUS_CANCELLED:
        body = 'Your booking has been cancelled.';
        break;
    }

    if (body.isNotEmpty) {
      _notificationService.sendBookingStatusNotification(
        userId: booking.customerId,
        bookingId: booking.id,
        status: newStatus,
      );
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(
    String bookingId,
    String newStatus, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add status-specific timestamps
      switch (newStatus) {
        case STATUS_EN_ROUTE:
          updateData['provider_arrival_time'] = DateTime.now()
              .toIso8601String();
          break;
        case STATUS_IN_PROGRESS:
          updateData['service_start_time'] = DateTime.now().toIso8601String();
          break;
        case STATUS_COMPLETED:
          updateData['service_end_time'] = DateTime.now().toIso8601String();
          break;
      }

      // Add any additional data
      if (additionalData != null) {
        updateData.addAll(Map<String, String>.from(additionalData));
      }

      await _supabase.from('bookings').update(updateData).eq('id', bookingId);

      return true;
    } catch (e) {
      debugPrint('Error updating booking status: $e');
      return false;
    }
  }

  // Get booking status history
  Future<List<Map<String, dynamic>>> getBookingStatusHistory(
    String bookingId,
  ) async {
    try {
      final response = await _supabase
          .from('booking_status_history')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting booking status history: $e');
      return [];
    }
  }

  // Add status update listener
  void addStatusUpdateListener(Function(BookingModel) listener) {
    _statusUpdateListeners.add(listener);
  }

  // Remove status update listener
  void removeStatusUpdateListener(Function(BookingModel) listener) {
    _statusUpdateListeners.remove(listener);
  }

  // Get status display information
  static Map<String, dynamic> getStatusInfo(String status) {
    switch (status) {
      case STATUS_PENDING:
        return {
          'title': 'Pending',
          'description': 'Waiting for confirmation',
          'icon': Icons.schedule,
          'color': Colors.orange,
        };
      case STATUS_CONFIRMED:
        return {
          'title': 'Confirmed',
          'description': 'Booking confirmed',
          'icon': Icons.check_circle,
          'color': Colors.green,
        };
      case STATUS_ASSIGNED:
        return {
          'title': 'Assigned',
          'description': 'Provider assigned',
          'icon': Icons.person_add,
          'color': Colors.blue,
        };
      case STATUS_EN_ROUTE:
        return {
          'title': 'En Route',
          'description': 'Provider is on the way',
          'icon': Icons.directions_car,
          'color': Colors.purple,
        };
      case STATUS_ARRIVED:
        return {
          'title': 'Arrived',
          'description': 'Provider has arrived',
          'icon': Icons.location_on,
          'color': Colors.indigo,
        };
      case STATUS_IN_PROGRESS:
        return {
          'title': 'In Progress',
          'description': 'Service in progress',
          'icon': Icons.build,
          'color': Colors.teal,
        };
      case STATUS_COMPLETED:
        return {
          'title': 'Completed',
          'description': 'Service completed',
          'icon': Icons.done_all,
          'color': Colors.green,
        };
      case STATUS_CANCELLED:
        return {
          'title': 'Cancelled',
          'description': 'Booking cancelled',
          'icon': Icons.cancel,
          'color': Colors.red,
        };
      default:
        return {
          'title': 'Unknown',
          'description': 'Unknown status',
          'icon': Icons.help,
          'color': Colors.grey,
        };
    }
  }

  // Get next possible statuses
  static List<String> getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case STATUS_PENDING:
        return [STATUS_CONFIRMED, STATUS_CANCELLED];
      case STATUS_CONFIRMED:
        return [STATUS_ASSIGNED, STATUS_CANCELLED];
      case STATUS_ASSIGNED:
        return [STATUS_EN_ROUTE, STATUS_CANCELLED];
      case STATUS_EN_ROUTE:
        return [STATUS_ARRIVED, STATUS_CANCELLED];
      case STATUS_ARRIVED:
        return [STATUS_IN_PROGRESS, STATUS_CANCELLED];
      case STATUS_IN_PROGRESS:
        return [STATUS_COMPLETED, STATUS_CANCELLED];
      case STATUS_COMPLETED:
        return [];
      case STATUS_CANCELLED:
        return [];
      default:
        return [];
    }
  }

  // Check if status transition is valid
  static bool isValidStatusTransition(String fromStatus, String toStatus) {
    final possibleNextStatuses = getNextPossibleStatuses(fromStatus);
    return possibleNextStatuses.contains(toStatus);
  }

  // Dispose resources
  void dispose() {
    _bookingStatusSubscription?.unsubscribe();
    _statusUpdateListeners.clear();
  }
}
