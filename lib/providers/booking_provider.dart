import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../models/service_provider_model.dart';
import '../services/booking_status_service.dart';
import '../services/booking_sync_service.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  List<ServiceProviderModel> _availableProviders = [];
  BookingModel? _currentBooking;
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  List<ServiceProviderModel> get availableProviders => _availableProviders;
  BookingModel? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final SupabaseClient _supabase = Supabase.instance.client;
  final BookingStatusService _statusService = BookingStatusService();
  final BookingSyncService _syncService = BookingSyncService();

  // Create a new booking
  Future<bool> createBooking({
    required String serviceCategory,
    required String serviceType,
    required String description,
    required double amount,
    required String paymentMethod,
    required DateTime scheduledDate,
    String? customerAddress,
    double? customerLatitude,
    double? customerLongitude,
    String? specialInstructions,
    List<String>? mediaUrls,
    String? audioUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final bookingData = {
        'customer_id': user.id,
        'service_category': serviceCategory,
        'service_type': serviceType,
        'description': description,
        'status': 'pending',
        'amount': amount,
        'payment_method': paymentMethod,
        'is_paid': false,
        'customer_address': customerAddress,
        'customer_latitude': customerLatitude,
        'customer_longitude': customerLongitude,
        'scheduled_date': scheduledDate.toIso8601String(),
        'special_instructions': specialInstructions,
        'media_urls': mediaUrls,
        'audio_url': audioUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      final newBooking = BookingModel.fromJson(response);
      _bookings.add(newBooking);
      _currentBooking = newBooking;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load user bookings
  Future<void> loadUserBookings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Use sync service to load bookings
      final bookings = await _syncService.syncUserBookings(user.id);
      _bookings = bookings;

      // Setup real-time synchronization
      _setupSyncListeners();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setup real-time synchronization listeners
  void _setupSyncListeners() {
    _syncService.addBookingsListUpdateListener((bookings) {
      _bookings = bookings;
      notifyListeners();
    });

    _statusService.addStatusUpdateListener((updatedBooking) {
      final index = _bookings.indexWhere(
        (booking) => booking.id == updatedBooking.id,
      );
      if (index != -1) {
        _bookings[index] = updatedBooking;
        notifyListeners();
      }
    });
  }

  // Get available service providers
  Future<void> getAvailableProviders({
    required String serviceCategory,
    double? latitude,
    double? longitude,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var query = _supabase
          .from('service_providers')
          .select()
          .eq('is_available', true)
          .contains('service_categories', [serviceCategory]);

      if (latitude != null && longitude != null) {
        // Add location-based filtering if needed
        // This is a simplified version - you might want to add proper distance calculation
      }

      final response = await query.order('rating', ascending: false);

      _availableProviders = response
          .map((json) => ServiceProviderModel.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Assign service provider to booking
  Future<bool> assignServiceProvider(
    String bookingId,
    String providerId,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase
          .from('bookings')
          .update({
            'service_provider_id': providerId,
            'status': 'assigned',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      // Update local booking
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          serviceProviderId: providerId,
          status: 'assigned',
          updatedAt: DateTime.now(),
        );
      }

      if (_currentBooking?.id == bookingId) {
        _currentBooking = _currentBooking!.copyWith(
          serviceProviderId: providerId,
          status: 'assigned',
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Use status service to update booking status
      final success = await _statusService.updateBookingStatus(
        bookingId,
        status,
      );

      if (success) {
        // The status service will handle real-time updates
        // Local updates will be handled by the sync listeners
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'cancelled_at': DateTime.now().toIso8601String(),
            'cancelled_by': 'customer',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      // Update local booking
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: 'cancelled',
          cancellationReason: reason,
          cancelledAt: DateTime.now(),
          cancelledBy: 'customer',
          updatedAt: DateTime.now(),
        );
      }

      if (_currentBooking?.id == bookingId) {
        _currentBooking = _currentBooking!.copyWith(
          status: 'cancelled',
          cancellationReason: reason,
          cancelledAt: DateTime.now(),
          cancelledBy: 'customer',
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Rate booking
  Future<bool> rateBooking(
    String bookingId,
    double rating,
    String review,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase
          .from('bookings')
          .update({
            'rating': rating,
            'review': review,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      // Update local booking
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          rating: rating,
          review: review,
          updatedAt: DateTime.now(),
        );
      }

      if (_currentBooking?.id == bookingId) {
        _currentBooking = _currentBooking!.copyWith(
          rating: rating,
          review: review,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set current booking
  void setCurrentBooking(BookingModel? booking) {
    _currentBooking = booking;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize real-time services
  Future<void> initializeServices() async {
    await _statusService.initialize();
    await _syncService.initialize();
  }

  // Dispose services
  @override
  void dispose() {
    _statusService.dispose();
    _syncService.dispose();
    super.dispose();
  }
}
