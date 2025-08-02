import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Review creation and management
  Future<ReviewModel> createReview({
    required String bookingId,
    required String providerId,
    required double rating,
    String? comment,
    List<String>? tags,
    Map<String, double>? categoryRatings,
    bool isAnonymous = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final reviewData = {
        'booking_id': bookingId,
        'user_id': user.id,
        'provider_id': providerId,
        'rating': rating,
        'comment': comment,
        'tags': tags,
        'category_ratings': categoryRatings,
        'is_anonymous': isAnonymous,
        'is_verified': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('reviews')
          .insert(reviewData)
          .select()
          .single();

      return ReviewModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating review: $e');
      rethrow;
    }
  }

  Future<ReviewModel> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
    List<String>? tags,
    Map<String, double>? categoryRatings,
    bool? isAnonymous,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (rating != null) updateData['rating'] = rating;
      if (comment != null) updateData['comment'] = comment;
      if (tags != null) updateData['tags'] = tags;
      if (categoryRatings != null)
        updateData['category_ratings'] = categoryRatings;
      if (isAnonymous != null) updateData['is_anonymous'] = isAnonymous;

      final response = await _supabase
          .from('reviews')
          .update(updateData)
          .eq('id', reviewId)
          .select()
          .single();

      return ReviewModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _supabase.from('reviews').delete().eq('id', reviewId);
    } catch (e) {
      debugPrint('Error deleting review: $e');
      rethrow;
    }
  }

  // Review fetching
  Future<List<ReviewModel>> getProviderReviews({
    required String providerId,
    int? limit,
    int? offset,
    String? sortBy,
    bool? sortDescending,
  }) async {
    try {
      // Build query step by step to avoid type conflicts
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('provider_id', providerId)
          .order(sortBy ?? 'created_at', ascending: !(sortDescending ?? false))
          .range(offset ?? 0, (offset ?? 0) + (limit ?? 10) - 1);

      return response.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching provider reviews: $e');
      rethrow;
    }
  }

  Future<List<ReviewModel>> getUserReviews({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabase
          .from('reviews')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return response.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching user reviews: $e');
      rethrow;
    }
  }

  Future<ReviewModel?> getReviewByBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) return null;
      return ReviewModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching review by booking: $e');
      rethrow;
    }
  }

  Future<ReviewModel?> getReviewById(String reviewId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('id', reviewId)
          .maybeSingle();

      if (response == null) return null;
      return ReviewModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching review by ID: $e');
      rethrow;
    }
  }

  // Review statistics
  Future<Map<String, dynamic>> getProviderReviewStats(String providerId) async {
    try {
      final reviews = await getProviderReviews(providerId: providerId);

      if (reviews.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': <int, int>{},
          'recentReviews': 0,
          'verifiedReviews': 0,
        };
      }

      final totalRating = reviews.fold<double>(
        0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      final ratingDistribution = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        ratingDistribution[i] = reviews
            .where((r) => r.rating.round() == i)
            .length;
      }

      final recentReviews = reviews.where((r) => r.isRecent).length;
      final verifiedReviews = reviews.where((r) => r.isVerified).length;

      return {
        'averageRating': averageRating,
        'totalReviews': reviews.length,
        'ratingDistribution': ratingDistribution,
        'recentReviews': recentReviews,
        'verifiedReviews': verifiedReviews,
      };
    } catch (e) {
      debugPrint('Error calculating review stats: $e');
      rethrow;
    }
  }

  // Review replies
  Future<ReviewModel> addReplyToReview({
    required String reviewId,
    required String reply,
    required String replyBy,
  }) async {
    try {
      final updateData = {
        'reply': reply,
        'reply_by': replyBy,
        'reply_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('reviews')
          .update(updateData)
          .eq('id', reviewId)
          .select()
          .single();

      return ReviewModel.fromJson(response);
    } catch (e) {
      debugPrint('Error adding reply to review: $e');
      rethrow;
    }
  }

  // Review verification
  Future<ReviewModel> verifyReview(String reviewId) async {
    try {
      final updateData = {
        'is_verified': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('reviews')
          .update(updateData)
          .eq('id', reviewId)
          .select()
          .single();

      return ReviewModel.fromJson(response);
    } catch (e) {
      debugPrint('Error verifying review: $e');
      rethrow;
    }
  }

  // Review filtering and search
  Future<List<ReviewModel>> searchReviews({
    required String providerId,
    String? searchQuery,
    double? minRating,
    double? maxRating,
    List<String>? tags,
    bool? isVerified,
    bool? isAnonymous,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // Build base query
      var query = _supabase
          .from('reviews')
          .select()
          .eq('provider_id', providerId);

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'comment.ilike.%$searchQuery%,user_name.ilike.%$searchQuery%',
        );
      }

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      if (maxRating != null) {
        query = query.lte('rating', maxRating);
      }

      if (isVerified != null) {
        query = query.eq('is_verified', isVerified);
      }

      if (isAnonymous != null) {
        query = query.eq('is_anonymous', isAnonymous);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      // Apply sorting
      final response = await query.order('created_at', ascending: false);
      var reviews = response.map((json) => ReviewModel.fromJson(json)).toList();

      // Filter by tags if specified
      if (tags != null && tags.isNotEmpty) {
        reviews = reviews.where((review) {
          if (review.tags == null) return false;
          return tags.any((tag) => review.tags!.contains(tag));
        }).toList();
      }

      return reviews;
    } catch (e) {
      debugPrint('Error searching reviews: $e');
      rethrow;
    }
  }

  // Review analytics
  Future<Map<String, dynamic>> getReviewAnalytics({
    required String providerId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _supabase
          .from('reviews')
          .select()
          .eq('provider_id', providerId);

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      final response = await query;
      final reviews = response
          .map((json) => ReviewModel.fromJson(json))
          .toList();

      if (reviews.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'ratingTrend': <String, double>{},
          'categoryAverages': <String, double>{},
          'responseRate': 0.0,
          'responseTime': 0.0,
        };
      }

      // Calculate rating trend by month
      final ratingTrend = <String, List<double>>{};
      for (final review in reviews) {
        final monthKey =
            '${review.createdAt.year}-${review.createdAt.month.toString().padLeft(2, '0')}';
        ratingTrend.putIfAbsent(monthKey, () => []).add(review.rating);
      }

      final averageRatingTrend = <String, double>{};
      for (final entry in ratingTrend.entries) {
        averageRatingTrend[entry.key] =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
      }

      // Calculate category averages
      final categoryAverages = <String, List<double>>{};
      for (final review in reviews) {
        if (review.categoryRatings != null) {
          for (final entry in review.categoryRatings!.entries) {
            categoryAverages.putIfAbsent(entry.key, () => []).add(entry.value);
          }
        }
      }

      final categoryAveragesResult = <String, double>{};
      for (final entry in categoryAverages.entries) {
        categoryAveragesResult[entry.key] =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
      }

      // Calculate response rate and time
      final reviewsWithReplies = reviews.where((r) => r.hasReply).length;
      final responseRate = reviewsWithReplies / reviews.length;

      double totalResponseTime = 0;
      int responseCount = 0;
      for (final review in reviews) {
        if (review.hasReply && review.replyDate != null) {
          final responseTime = review.replyDate!
              .difference(review.createdAt)
              .inHours;
          totalResponseTime += responseTime;
          responseCount++;
        }
      }
      final averageResponseTime = responseCount > 0
          ? totalResponseTime / responseCount
          : 0.0;

      return {
        'totalReviews': reviews.length,
        'averageRating':
            reviews.fold<double>(0, (sum, r) => sum + r.rating) /
            reviews.length,
        'ratingTrend': averageRatingTrend,
        'categoryAverages': categoryAveragesResult,
        'responseRate': responseRate,
        'responseTime': averageResponseTime,
      };
    } catch (e) {
      debugPrint('Error calculating review analytics: $e');
      rethrow;
    }
  }

  // Check if user can review a booking
  Future<bool> canUserReviewBooking(String bookingId, String userId) async {
    try {
      // Check if booking exists and belongs to user
      final bookingResponse = await _supabase
          .from('bookings')
          .select('status')
          .eq('id', bookingId)
          .eq('customer_id', userId)
          .maybeSingle();

      if (bookingResponse == null) return false;

      // Check if booking is completed
      if (bookingResponse['status'] != 'completed') return false;

      // Check if review already exists
      final existingReview = await getReviewByBooking(bookingId);
      return existingReview == null;
    } catch (e) {
      debugPrint('Error checking if user can review booking: $e');
      return false;
    }
  }
}
