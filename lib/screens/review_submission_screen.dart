import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ReviewSubmissionScreen extends StatefulWidget {
  final BookingModel booking;
  final String providerId;
  final String providerName;

  const ReviewSubmissionScreen({
    super.key,
    required this.booking,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<ReviewSubmissionScreen> createState() => _ReviewSubmissionScreenState();
}

class _ReviewSubmissionScreenState extends State<ReviewSubmissionScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();

  double _overallRating = 0.0;
  Map<String, double> _categoryRatings = {};
  List<String> _selectedTags = [];
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  String? _error;
  String? _successMessage;

  final List<String> _availableTags = [
    'Professional',
    'Punctual',
    'Clean',
    'Skilled',
    'Friendly',
    'Reliable',
    'Affordable',
    'Quick',
    'Thorough',
    'Helpful',
  ];

  final List<String> _ratingCategories = [
    'Service Quality',
    'Professionalism',
    'Punctuality',
    'Communication',
    'Value for Money',
  ];

  @override
  void initState() {
    super.initState();
    _initializeCategoryRatings();
  }

  void _initializeCategoryRatings() {
    for (final category in _ratingCategories) {
      _categoryRatings[category] = 0.0;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_overallRating == 0.0) {
      setState(() {
        _error = 'Please provide an overall rating';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final review = await _reviewService.createReview(
        bookingId: widget.booking.id,
        providerId: widget.providerId,
        rating: _overallRating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        tags: _selectedTags.isEmpty ? null : _selectedTags,
        categoryRatings: _categoryRatings.values.every((rating) => rating > 0)
            ? _categoryRatings
            : null,
        isAnonymous: _isAnonymous,
      );

      setState(() {
        _successMessage = 'Review submitted successfully!';
        _isSubmitting = false;
      });

      // Show success dialog
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to submit review: $e';
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Review Submitted'),
        content: const Text(
          'Thank you for your feedback! Your review helps other users make informed decisions.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24.0),

            // Overall Rating
            _buildOverallRating(),
            const SizedBox(height: 24.0),

            // Category Ratings
            _buildCategoryRatings(),
            const SizedBox(height: 24.0),

            // Tags Selection
            _buildTagsSelection(),
            const SizedBox(height: 24.0),

            // Comment Section
            _buildCommentSection(),
            const SizedBox(height: 24.0),

            // Anonymous Option
            _buildAnonymousOption(),
            const SizedBox(height: 24.0),

            // Error Message
            if (_error != null) _buildErrorMessage(),
            if (_successMessage != null) _buildSuccessMessage(),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate your experience with',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.providerName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Service: ${widget.booking.serviceType}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRating() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Rating',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Center(
              child: StarRatingWidget(
                initialRating: _overallRating,
                size: 32.0,
                onRatingChanged: (rating) {
                  setState(() {
                    _overallRating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                _overallRating > 0
                    ? '${_overallRating.toStringAsFixed(1)} stars'
                    : 'Tap to rate',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRatings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate Specific Aspects',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Rate different aspects of the service (optional)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16.0),
            ..._ratingCategories.map(
              (category) => _buildCategoryRating(category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRating(String category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: StarRatingWidget(
              initialRating: _categoryRatings[category] ?? 0.0,
              size: 20.0,
              onRatingChanged: (rating) {
                setState(() {
                  _categoryRatings[category] = rating;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What went well?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Select tags that describe your experience (optional)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _availableTags
                  .map((tag) => _buildTagChip(tag))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = _selectedTags.contains(tag);
    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (_) => _toggleTag(tag),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildCommentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Comments',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Share your experience in detail (optional)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12.0),
            CustomTextField(
              controller: _commentController,
              labelText: 'Write your review...',
              hintText:
                  'Tell us about your experience with this service provider',
              maxLines: 4,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousOption() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit Anonymously',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Your name will be hidden from the review',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(_error!, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[600]),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: _isSubmitting ? null : _submitReview,
        text: _isSubmitting ? 'Submitting...' : 'Submit Review',
      ),
    );
  }
}
