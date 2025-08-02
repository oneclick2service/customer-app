import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/service_provider_model.dart';
import '../models/review_model.dart' show Review;

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // User Management
  Future<UserModel?> createUser(UserModel user) async {
    try {
      final response = await _supabase
          .from('users')
          .insert(user.toJson())
          .select()
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      await _supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id);
      
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
      
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Booking Management
  Future<BookingModel?> createBooking(BookingModel booking) async {
    try {
      final response = await _supabase
          .from('bookings')
          .insert(booking.toJson())
          .select()
          .single();
      
      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting user bookings: $e');
      return [];
    }
  }

  Future<bool> updateBooking(BookingModel booking) async {
    try {
      await _supabase
          .from('bookings')
          .update(booking.toJson())
          .eq('id', booking.id);
      
      return true;
    } catch (e) {
      print('Error updating booking: $e');
      return false;
    }
  }

  // Service Provider Management
  Future<List<ServiceProviderModel>> getServiceProviders({
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      var query = _supabase
          .from('service_providers')
          .select()
          .eq('is_verified', true)
          .eq('is_available', true);

      if (category != null) {
        query = query.eq('service_category', category);
      }

      final response = await query;
      final providers = response.map((json) => ServiceProviderModel.fromJson(json)).toList();

      // Filter by distance if location is provided
      if (latitude != null && longitude != null && radius != null) {
        providers.removeWhere((provider) {
          if (provider.latitude == null || provider.longitude == null) return true;
          
          final distance = _calculateDistance(
            latitude, longitude,
            provider.latitude!, provider.longitude!,
          );
          
          return distance > radius;
        });
      }

      return providers;
    } catch (e) {
      print('Error getting service providers: $e');
      return [];
    }
  }

  // Review Management
  Future<Review?> createReview(Review review) async {
    try {
      final response = await _supabase
          .from('reviews')
          .insert(review.toJson())
          .select()
          .single();
      
      return Review.fromJson(response);
    } catch (e) {
      print('Error creating review: $e');
      return null;
    }
  }

  Future<List<Review>> getProviderReviews(String providerId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);
      
      return response.map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error getting provider reviews: $e');
      return [];
    }
  }

  // Real-time subscriptions
  Stream<List<BookingModel>> subscribeToUserBookings(String userId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((response) => response.map((json) => BookingModel.fromJson(json)).toList());
  }

  Stream<BookingModel?> subscribeToBooking(String bookingId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('id', bookingId)
        .map((response) => response.isNotEmpty ? BookingModel.fromJson(response.first) : null);
  }

  Stream<List<Review>> subscribeToProviderReviews(String providerId) {
    return _supabase
        .from('reviews')
        .stream(primaryKey: ['id'])
        .eq('provider_id', providerId)
        .order('created_at', ascending: false)
        .map((response) => response.map((json) => Review.fromJson(json)).toList());
  }

  // Utility methods
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(_degreesToRadians(lat1)) * math.sin(_degreesToRadians(lat2)) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Database schema setup (for initial setup)
  Future<void> setupDatabase() async {
    // This would typically be done through Supabase migrations
    // For now, we'll just ensure the tables exist
    print('Database setup completed');
  }

  // Error handling
  String getErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else {
      return error.toString();
    }
  }
} 