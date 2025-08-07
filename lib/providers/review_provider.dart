import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get filtered reviews for moderation
  Future<List<Review>> getFilteredReviews({
    required String providerId,
    String filter = 'all',
    String sort = 'recent',
    String searchQuery = '',
    bool reportedOnly = false,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final reviews = await _reviewService.getFilteredReviews(
        providerId: providerId,
        filter: filter,
        sort: sort,
        searchQuery: searchQuery,
        reportedOnly: reportedOnly,
      );

      _reviews = reviews;
      _isLoading = false;
      notifyListeners();

      return reviews;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get reviews for a specific provider
  Future<List<Review>> getProviderReviews(String providerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final reviews = await _reviewService.getProviderReviews(providerId: providerId);
      _reviews = reviews;
      _isLoading = false;
      notifyListeners();

      return reviews;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Submit a new review
  Future<bool> submitReview(Review review) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _reviewService.submitReview(review);

      if (success) {
        // Add the new review to the list
        _reviews.insert(0, review);
        notifyListeners();
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

  // Update an existing review
  Future<bool> updateReview(Review review) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _reviewService.updateReview(reviewId: review.id);

      if (success != null) {
        // Update the review in the list
        final index = _reviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          _reviews[index] = review;
          notifyListeners();
        }
      }

      _isLoading = false;
      notifyListeners();

      return success != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _reviewService.deleteReview(reviewId);

      // Remove the review from the list
      _reviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();

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

  // Toggle helpful status
  Future<bool> toggleHelpful(String reviewId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _reviewService.toggleHelpful(reviewId);

      if (success) {
        // Update the review in the list
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          final review = _reviews[index];
          _reviews[index] = review.copyWith(
            helpfulCount: review.isHelpful ? review.helpfulCount - 1 : review.helpfulCount + 1,
            isHelpful: !review.isHelpful,
          );
          notifyListeners();
        }
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

  // Report a review
  Future<bool> reportReview(String reviewId, String reason) async {
    try {
      final success = await _reviewService.reportReview(reviewId, reason);

      if (success) {
        // Update the review's reported status in the list
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          final review = _reviews[index];
          final updatedReview = review.copyWith(isReported: true);
          _reviews[index] = updatedReview;
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Approve a reported review (moderation)
  Future<bool> approveReview(String reviewId) async {
    try {
      final success = await _reviewService.approveReview(reviewId);

      if (success) {
        // Update the review's reported status in the list
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          final review = _reviews[index];
          final updatedReview = review.copyWith(isReported: false);
          _reviews[index] = updatedReview;
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove a review (moderation)
  Future<bool> removeReview(String reviewId) async {
    try {
      final success = await _reviewService.removeReview(reviewId);

      if (success) {
        // Remove the review from the list
        _reviews.removeWhere((r) => r.id == reviewId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get review statistics for a provider
  Future<Map<String, dynamic>> getReviewStatistics(String providerId) async {
    try {
      return await _reviewService.getReviewStatistics(providerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get user's reviews
  Future<List<Review>> getUserReviews(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final reviews = await _reviewService.getUserReviews(userId: userId);
      _reviews = reviews;
      _isLoading = false;
      notifyListeners();

      return reviews;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Check if user has reviewed a provider
  Future<Review?> getUserReviewForProvider(
    String userId,
    String providerId,
  ) async {
    try {
      return await _reviewService.getUserReviewForProvider(userId, providerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear reviews
  void clearReviews() {
    _reviews.clear();
    notifyListeners();
  }
}
