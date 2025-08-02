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

  // New methods for Review model compatibility and moderation
  Future<bool> submitReview(Review review) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final reviewData = {
        'provider_id': review.providerId,
        'user_id': review.userId,
        'user_name': review.userName,
        'user_profile_image': review.userProfileImage,
        'rating': review.rating,
        'comment': review.comment,
        'aspect_ratings': review.aspectRatings,
        'helpful_count': review.helpfulCount,
        'is_helpful': review.isHelpful,
        'is_reported': review.isReported,
        'created_at': review.createdAt.toIso8601String(),
        'updated_at': review.updatedAt.toIso8601String(),
      };

      await _supabase.from('reviews').insert(reviewData);
      return true;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return false;
    }
  }

  Future<bool> updateReview(Review review) async {
    try {
      final updateData = {
        'rating': review.rating,
        'comment': review.comment,
        'aspect_ratings': review.aspectRatings,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('reviews').update(updateData).eq('id', review.id);

      return true;
    } catch (e) {
      debugPrint('Error updating review: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _supabase.from('reviews').delete().eq('id', reviewId);
      return true;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  Future<List<Review>> getProviderReviews(String providerId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Return mock data for now
      return [
        Review(
          id: '1',
          providerId: providerId,
          userId: 'user1',
          userName: 'John Doe',
          userProfileImage: null,
          rating: 5,
          comment: 'Excellent service! Very professional and punctual.',
          aspectRatings: {'punctuality': 5, 'quality': 5, 'communication': 4},
          helpfulCount: 12,
          isHelpful: false,
          isReported: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: '2',
          providerId: providerId,
          userId: 'user2',
          userName: 'Jane Smith',
          userProfileImage: null,
          rating: 4,
          comment: 'Good work, but took a bit longer than expected.',
          aspectRatings: {'punctuality': 3, 'quality': 4, 'communication': 5},
          helpfulCount: 8,
          isHelpful: true,
          isReported: false,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Review(
          id: '3',
          providerId: providerId,
          userId: 'user3',
          userName: 'Mike Johnson',
          userProfileImage: null,
          rating: 3,
          comment: 'Average service. Could be better.',
          aspectRatings: {'punctuality': 2, 'quality': 3, 'communication': 4},
          helpfulCount: 3,
          isHelpful: false,
          isReported: true,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch provider reviews: $e');
    }
  }

  Future<List<Review>> getFilteredReviews({
    required String providerId,
    String filter = 'all',
    String sort = 'recent',
    String searchQuery = '',
    bool reportedOnly = false,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Get all reviews first
      List<Review> allReviews = await getProviderReviews(providerId);

      // Apply filters
      List<Review> filteredReviews = allReviews.where((review) {
        // Filter by rating
        if (filter != 'all') {
          int ratingFilter = int.parse(filter.split('_')[0]);
          if (review.rating != ratingFilter) return false;
        }

        // Filter by reported status
        if (reportedOnly && !review.isReported) return false;

        // Filter by search query
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          final matchesComment = review.comment.toLowerCase().contains(query);
          final matchesUserName = review.userName.toLowerCase().contains(query);
          if (!matchesComment && !matchesUserName) return false;
        }

        return true;
      }).toList();

      // Apply sorting
      switch (sort) {
        case 'recent':
          filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'oldest':
          filteredReviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'highest_rating':
          filteredReviews.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'lowest_rating':
          filteredReviews.sort((a, b) => a.rating.compareTo(b.rating));
          break;
        case 'most_helpful':
          filteredReviews.sort(
            (a, b) => b.helpfulCount.compareTo(a.helpfulCount),
          );
          break;
        case 'least_helpful':
          filteredReviews.sort(
            (a, b) => a.helpfulCount.compareTo(b.helpfulCount),
          );
          break;
      }

      return filteredReviews;
    } catch (e) {
      throw Exception('Failed to fetch filtered reviews: $e');
    }
  }

  Future<bool> toggleHelpful(String reviewId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      debugPrint('Error toggling helpful: $e');
      return false;
    }
  }

  Future<bool> reportReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .update({'is_reported': true})
          .eq('id', reviewId);
      return true;
    } catch (e) {
      debugPrint('Error reporting review: $e');
      return false;
    }
  }

  Future<bool> approveReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .update({'is_reported': false})
          .eq('id', reviewId);
      return true;
    } catch (e) {
      debugPrint('Error approving review: $e');
      return false;
    }
  }

  Future<bool> removeReview(String reviewId) async {
    try {
      await _supabase.from('reviews').delete().eq('id', reviewId);
      return true;
    } catch (e) {
      debugPrint('Error removing review: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getReviewStatistics(String providerId) async {
    try {
      final reviews = await getProviderReviews(providerId);

      if (reviews.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': <int, int>{},
          'recentReviews': 0,
          'reportedReviews': 0,
        };
      }

      final totalRating = reviews.fold<double>(
        0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      final ratingDistribution = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        ratingDistribution[i] = reviews.where((r) => r.rating == i).length;
      }

      final recentReviews = reviews
          .where(
            (r) => r.createdAt.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            ),
          )
          .length;

      final reportedReviews = reviews.where((r) => r.isReported).length;

      return {
        'averageRating': averageRating,
        'totalReviews': reviews.length,
        'ratingDistribution': ratingDistribution,
        'recentReviews': recentReviews,
        'reportedReviews': reportedReviews,
      };
    } catch (e) {
      debugPrint('Error calculating review statistics: $e');
      rethrow;
    }
  }

  Future<List<Review>> getUserReviews(String userId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      return [
        Review(
          id: '1',
          providerId: 'provider1',
          userId: userId,
          userName: 'John Doe',
          userProfileImage: null,
          rating: 5,
          comment: 'Great service!',
          aspectRatings: {'punctuality': 5, 'quality': 5, 'communication': 4},
          helpfulCount: 5,
          isHelpful: false,
          isReported: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  Future<Review?> getUserReviewForProvider(
    String userId,
    String providerId,
  ) async {
    try {
      final reviews = await getUserReviews(userId);
      return reviews.where((r) => r.providerId == providerId).firstOrNull;
    } catch (e) {
      debugPrint('Error getting user review for provider: $e');
      return null;
    }
  }
}
