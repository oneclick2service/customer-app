import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class BookingSyncService {
  static final BookingSyncService _instance = BookingSyncService._internal();
  factory BookingSyncService() => _instance;
  BookingSyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _syncSubscription;
  final List<Function(BookingModel)> _bookingUpdateListeners = [];
  final List<Function(List<BookingModel>)> _bookingsListUpdateListeners = [];

  // Initialize real-time synchronization
  Future<void> initialize() async {
    await _setupSyncSubscription();
  }

  // Setup real-time subscription for booking updates
  Future<void> _setupSyncSubscription() async {
    try {
      _syncSubscription = _supabase
          .channel('booking_sync')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'bookings',
            callback: (payload) {
              _handleBookingUpdate(payload);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'bookings',
            callback: (payload) {
              _handleBookingInsert(payload);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'bookings',
            callback: (payload) {
              _handleBookingDelete(payload);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error setting up booking sync subscription: $e');
    }
  }

  // Handle booking updates from Supabase Realtime
  void _handleBookingUpdate(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord as Map<String, dynamic>;
      final oldRecord = payload.oldRecord as Map<String, dynamic>;

      final booking = BookingModel.fromJson(newRecord);

      // Notify all listeners about the updated booking
      for (final listener in _bookingUpdateListeners) {
        listener(booking);
      }

      // Update booking provider if available
      _updateBookingProvider(booking);
    } catch (e) {
      debugPrint('Error handling booking update: $e');
    }
  }

  // Handle booking inserts from Supabase Realtime
  void _handleBookingInsert(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord as Map<String, dynamic>;
      final booking = BookingModel.fromJson(newRecord);

      // Notify all listeners about the new booking
      for (final listener in _bookingUpdateListeners) {
        listener(booking);
      }

      // Update booking provider if available
      _updateBookingProvider(booking);
    } catch (e) {
      debugPrint('Error handling booking insert: $e');
    }
  }

  // Handle booking deletes from Supabase Realtime
  void _handleBookingDelete(PostgresChangePayload payload) {
    try {
      final oldRecord = payload.oldRecord as Map<String, dynamic>;
      final bookingId = oldRecord['id'] as String;

      // Notify listeners about the deleted booking
      // You might want to create a special event for deletions
      debugPrint('Booking deleted: $bookingId');
    } catch (e) {
      debugPrint('Error handling booking delete: $e');
    }
  }

  // Update booking provider with new booking data
  void _updateBookingProvider(BookingModel updatedBooking) {
    // This will be called by the provider when it's available
    // The provider should listen to this service and update its state
  }

  // Add booking update listener
  void addBookingUpdateListener(Function(BookingModel) listener) {
    _bookingUpdateListeners.add(listener);
  }

  // Remove booking update listener
  void removeBookingUpdateListener(Function(BookingModel) listener) {
    _bookingUpdateListeners.remove(listener);
  }

  // Add bookings list update listener
  void addBookingsListUpdateListener(Function(List<BookingModel>) listener) {
    _bookingsListUpdateListeners.add(listener);
  }

  // Remove bookings list update listener
  void removeBookingsListUpdateListener(Function(List<BookingModel>) listener) {
    _bookingsListUpdateListeners.remove(listener);
  }

  // Sync all user bookings
  Future<List<BookingModel>> syncUserBookings(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      final bookings = response
          .map((json) => BookingModel.fromJson(json))
          .toList();

      // Notify listeners about the updated bookings list
      for (final listener in _bookingsListUpdateListeners) {
        listener(bookings);
      }

      return bookings;
    } catch (e) {
      debugPrint('Error syncing user bookings: $e');
      return [];
    }
  }

  // Get real-time booking updates for a specific booking
  Future<BookingModel?> getBookingUpdates(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      return BookingModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting booking updates: $e');
      return null;
    }
  }

  // Subscribe to specific booking updates
  void subscribeToBooking(String bookingId, Function(BookingModel) callback) {
    _supabase
        .channel('booking_$bookingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: bookingId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord as Map<String, dynamic>;
            final booking = BookingModel.fromJson(newRecord);
            callback(booking);
          },
        )
        .subscribe();
  }

  // Unsubscribe from specific booking updates
  void unsubscribeFromBooking(String bookingId) {
    _supabase.channel('booking_$bookingId').unsubscribe();
  }

  // Get booking status changes
  Future<List<Map<String, dynamic>>> getBookingStatusChanges(
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
      debugPrint('Error getting booking status changes: $e');
      return [];
    }
  }

  // Force refresh all bookings
  Future<void> forceRefreshBookings(String userId) async {
    try {
      final bookings = await syncUserBookings(userId);

      // Notify all listeners about the refreshed bookings
      for (final listener in _bookingsListUpdateListeners) {
        listener(bookings);
      }
    } catch (e) {
      debugPrint('Error forcing refresh bookings: $e');
    }
  }

  // Check for booking conflicts
  Future<bool> checkBookingConflicts(
    String userId,
    DateTime scheduledDate,
  ) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('id, scheduled_date, status')
          .eq('customer_id', userId)
          .eq('status', 'confirmed')
          .gte(
            'scheduled_date',
            scheduledDate.subtract(const Duration(hours: 2)).toIso8601String(),
          )
          .lte(
            'scheduled_date',
            scheduledDate.add(const Duration(hours: 2)).toIso8601String(),
          );

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking booking conflicts: $e');
      return false;
    }
  }

  // Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('status, created_at')
          .eq('customer_id', userId);

      final bookings = response as List;

      final statistics = {
        'total': bookings.length,
        'pending': bookings.where((b) => b['status'] == 'pending').length,
        'confirmed': bookings.where((b) => b['status'] == 'confirmed').length,
        'completed': bookings.where((b) => b['status'] == 'completed').length,
        'cancelled': bookings.where((b) => b['status'] == 'cancelled').length,
        'this_month': bookings.where((b) {
          final createdAt = DateTime.parse(b['created_at']);
          final now = DateTime.now();
          return createdAt.year == now.year && createdAt.month == now.month;
        }).length,
      };

      return statistics;
    } catch (e) {
      debugPrint('Error getting booking statistics: $e');
      return {
        'total': 0,
        'pending': 0,
        'confirmed': 0,
        'completed': 0,
        'cancelled': 0,
        'this_month': 0,
      };
    }
  }

  // Dispose resources
  void dispose() {
    _syncSubscription?.unsubscribe();
    _bookingUpdateListeners.clear();
    _bookingsListUpdateListeners.clear();
  }
}
