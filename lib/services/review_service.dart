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
      int recentReviews = 0;
      int verifiedReviews = 0;

      for (final review in reviews) {
        ratingDistribution[review.rating] =
            (ratingDistribution[review.rating] ?? 0) + 1;

        if (review.createdAt.isAfter(
          DateTime.now().subtract(const Duration(days: 30)),
        )) {
          recentReviews++;
        }

        if (review.isVerified) {
          verifiedReviews++;
        }
      }

      return {
        'averageRating': averageRating,
        'totalReviews': reviews.length,
        'ratingDistribution': ratingDistribution,
        'recentReviews': recentReviews,
        'verifiedReviews': verifiedReviews,
      };
    } catch (e) {
      debugPrint('Error fetching review stats: $e');
      rethrow;
    }
  }

  // Review search
  Future<List<ReviewModel>> searchReviews({
    required String providerId,
    required String searchQuery,
  }) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('provider_id', providerId)
          .textSearch('comment', searchQuery)
          .order('created_at', ascending: false);

      return response.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching reviews: $e');
      rethrow;
    }
  }

  // Review interactions
  Future<bool> markReviewHelpful(String reviewId, bool isHelpful) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updateData = {
        'helpful_count': isHelpful ? 1 : -1,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('reviews')
          .update(updateData)
          .eq('id', reviewId);

      return true;
    } catch (e) {
      debugPrint('Error marking review helpful: $e');
      return false;
    }
  }

  Future<bool> reportReview(String reviewId, String reason) async {
    try {
      await _supabase
          .from('reviews')
          .update({
            'is_reported': true,
            'report_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);

      return true;
    } catch (e) {
      debugPrint('Error reporting review: $e');
      return false;
    }
  }

  // Provider response
  Future<bool> addProviderResponse({
    required String reviewId,
    required String response,
    List<String>? attachments,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final responseData = {
        'review_id': reviewId,
        'provider_id': user.id,
        'response': response,
        'attachments': attachments,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('review_responses').insert(responseData);

      // Update review with response info
      await _supabase
          .from('reviews')
          .update({
            'has_response': true,
            'response_date': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);

      return true;
    } catch (e) {
      debugPrint('Error adding provider response: $e');
      return false;
    }
  }

  // Review analytics
  Future<Map<String, dynamic>> getReviewAnalytics(String providerId) async {
    try {
      final reviews = await getProviderReviews(providerId: providerId);

      if (reviews.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'ratingTrend': <String, double>{},
          'responseRate': 0.0,
          'topTags': <String>[],
        };
      }

      // Calculate analytics
      final totalReviews = reviews.length;
      final averageRating = reviews.fold<double>(0, (sum, r) => sum + r.rating) /
          totalReviews;

      // Rating trend (last 6 months)
      final ratingTrend = <String, double>{};
      final now = DateTime.now();
      for (int i = 5; i >= 0; i--) {
        final month = now.subtract(Duration(days: 30 * i));
        final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
        
        final monthReviews = reviews.where((r) =>
            r.createdAt.year == month.year && r.createdAt.month == month.month);
        
        if (monthReviews.isNotEmpty) {
          ratingTrend[monthKey] = monthReviews.fold<double>(0, (sum, r) => sum + r.rating) /
              monthReviews.length;
        } else {
          ratingTrend[monthKey] = 0.0;
        }
      }

      // Response rate
      final reviewsWithResponse = reviews.where((r) => r.hasReply).length;
      final responseRate = (reviewsWithResponse / totalReviews) * 100;

      // Top tags
      final tagCounts = <String, int>{};
      for (final review in reviews) {
        if (review.tags != null) {
          for (final tag in review.tags!) {
            tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
          }
        }
      }

      final topTags = tagCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      final topTagsList = topTags.take(5).map((e) => e.key).toList();

      return {
        'totalReviews': totalReviews,
        'averageRating': averageRating,
        'ratingTrend': ratingTrend,
        'responseRate': responseRate,
        'topTags': topTagsList,
      };
    } catch (e) {
      debugPrint('Error fetching review analytics: $e');
      rethrow;
    }
  }

  // Review moderation
  Future<bool> moderateReview(String reviewId, String action) async {
    try {
      final updateData = {
        'moderation_status': action,
        'moderated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('reviews')
          .update(updateData)
          .eq('id', reviewId);

      return true;
    } catch (e) {
      debugPrint('Error moderating review: $e');
      return false;
    }
  }

  // Review export
  Future<String> exportReviews(String providerId) async {
    try {
      final reviews = await getProviderReviews(providerId: providerId);
      
      final csvData = StringBuffer();
      csvData.writeln('Review ID,User,Rating,Comment,Date,Status');
      
      for (final review in reviews) {
        csvData.writeln(
          '${review.id},${review.userName},${review.rating},"${review.comment}",${review.createdAt.toIso8601String()},${review.isReported ? "Reported" : "Active"}',
        );
      }
      
      return csvData.toString();
    } catch (e) {
      debugPrint('Error exporting reviews: $e');
      rethrow;
    }
  }

  // Submit a review (for ReviewProvider compatibility)
  Future<bool> submitReview(Review review) async {
    try {
      final reviewData = {
        'provider_id': review.providerId,
        'user_id': review.userId,
        'user_name': review.userName,
        'rating': review.rating,
        'comment': review.comment,
        'aspect_ratings': review.aspectRatings,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('reviews').insert(reviewData);
      return true;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return false;
    }
  }

  // Get filtered reviews (for ReviewProvider compatibility)
  Future<List<Review>> getFilteredReviews({
    required String providerId,
    String filter = 'all',
    String sort = 'recent',
    String searchQuery = '',
    bool reportedOnly = false,
  }) async {
    try {
      // For now, return a simple filtered list
      final reviews = await getProviderReviews(providerId: providerId);
      
      var filteredReviews = reviews;
      
      if (reportedOnly) {
        filteredReviews = reviews.where((r) => r.isReported).toList();
      }
      
      if (searchQuery.isNotEmpty) {
        filteredReviews = filteredReviews
            .where((r) => r.comment.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
      
      // Apply sorting
      switch (sort) {
        case 'recent':
          filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'rating':
          filteredReviews.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'helpful':
          filteredReviews.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
          break;
        default:
          filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      return filteredReviews;
    } catch (e) {
      debugPrint('Error fetching filtered reviews: $e');
      rethrow;
    }
  }

  // Toggle helpful status
  Future<bool> toggleHelpful(String reviewId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('helpful_count, is_helpful')
          .eq('id', reviewId)
          .single();

      final currentHelpfulCount = response['helpful_count'] as int? ?? 0;
      final currentIsHelpful = response['is_helpful'] as bool? ?? false;

      await _supabase
          .from('reviews')
          .update({
            'helpful_count': currentIsHelpful ? currentHelpfulCount - 1 : currentHelpfulCount + 1,
            'is_helpful': !currentIsHelpful,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);

      return true;
    } catch (e) {
      debugPrint('Error toggling helpful status: $e');
      return false;
    }
  }

  // Approve a review (for moderation)
  Future<bool> approveReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .update({
            'moderation_status': 'approved',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);

      return true;
    } catch (e) {
      debugPrint('Error approving review: $e');
      return false;
    }
  }

  // Remove a review (for moderation)
  Future<bool> removeReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .update({
            'moderation_status': 'removed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);

      return true;
    } catch (e) {
      debugPrint('Error removing review: $e');
      return false;
    }
  }

  // Get user review for a specific provider
  Future<ReviewModel?> getUserReviewForProvider(String userId, String providerId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('user_id', userId)
          .eq('provider_id', providerId)
          .maybeSingle();

      if (response == null) return null;
      return ReviewModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching user review for provider: $e');
      return null;
    }
  }

  // Get review statistics
  Future<Map<String, dynamic>> getReviewStatistics(String providerId) async {
    try {
      final reviews = await getProviderReviews(providerId: providerId);
      
      if (reviews.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
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
      int recentReviews = 0;
      int verifiedReviews = 0;

      for (final review in reviews) {
        ratingDistribution[review.rating] =
            (ratingDistribution[review.rating] ?? 0) + 1;

        if (review.createdAt.isAfter(
          DateTime.now().subtract(const Duration(days: 30)),
        )) {
          recentReviews++;
        }

        if (review.isVerified) {
          verifiedReviews++;
        }
      }

      return {
        'totalReviews': reviews.length,
        'averageRating': averageRating,
        'ratingDistribution': ratingDistribution,
        'recentReviews': recentReviews,
        'verifiedReviews': verifiedReviews,
      };
    } catch (e) {
      debugPrint('Error fetching review statistics: $e');
      rethrow;
    }
  }
} 