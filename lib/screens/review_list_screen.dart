import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/custom_button.dart';

class ReviewListScreen extends StatefulWidget {
  final String providerId;
  final String providerName;

  const ReviewListScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  final ReviewService _reviewService = ReviewService();

  List<ReviewModel> _reviews = [];
  Map<String, dynamic>? _reviewStats;
  bool _isLoading = true;
  String? _error;

  // Filter states
  String _selectedSortBy = 'date';
  bool _sortDescending = true;
  String _selectedRatingFilter = 'All';
  String _searchQuery = '';

  // Pagination
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _hasMoreReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _hasMoreReviews = true;
      });
    }

    if (!_hasMoreReviews && !refresh) return;

    setState(() {
      if (refresh) {
        _isLoading = true;
        _reviews.clear();
      }
      _error = null;
    });

    try {
      final reviews = await _reviewService.getProviderReviews(
        providerId: widget.providerId,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        sortBy: _selectedSortBy,
        sortDescending: _sortDescending,
      );

      if (refresh) {
        _reviews = reviews;
      } else {
        _reviews.addAll(reviews);
      }

      _hasMoreReviews = reviews.length == _pageSize;
      _currentPage++;

      // Load review stats if not loaded
      if (_reviewStats == null) {
        _loadReviewStats();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reviews: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReviewStats() async {
    try {
      final stats = await _reviewService.getProviderReviewStats(
        widget.providerId,
      );
      setState(() {
        _reviewStats = stats;
      });
    } catch (e) {
      debugPrint('Error loading review stats: $e');
    }
  }

  Future<void> _searchReviews() async {
    if (_searchQuery.trim().isEmpty) {
      await _loadReviews(refresh: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reviews = await _reviewService.searchReviews(
        providerId: widget.providerId,
        searchQuery: _searchQuery.trim(),
      );

      setState(() {
        _reviews = reviews;
        _isLoading = false;
        _hasMoreReviews = false; // Disable pagination for search results
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search reviews: $e';
        _isLoading = false;
      });
    }
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _selectedSortBy = sortBy;
    });
    _loadReviews(refresh: true);
  }

  void _onRatingFilterChanged(String rating) {
    setState(() {
      _selectedRatingFilter = rating;
    });
    _loadReviews(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews - ${widget.providerName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Review Stats
          if (_reviewStats != null) _buildReviewStats(),

          // Search and Filters
          _buildSearchAndFilters(),

          // Reviews List
          Expanded(child: _buildReviewsList()),
        ],
      ),
    );
  }

  Widget _buildReviewStats() {
    final stats = _reviewStats!;
    final averageRating = stats['averageRating'] as double;
    final totalReviews = stats['totalReviews'] as int;
    final ratingDistribution =
        stats['ratingDistribution'] as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Rating',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          StarRatingDisplay(
                            rating: averageRating,
                            size: 24.0,
                            showRating: true,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            '($totalReviews reviews)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      'out of 5',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildRatingDistribution(ratingDistribution),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(Map<String, dynamic> distribution) {
    final totalReviews = distribution.values.fold<int>(
      0,
      (sum, count) => sum + (count as int),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Distribution',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        ...List.generate(5, (index) {
          final rating = 5 - index;
          final count = distribution[rating.toString()] as int? ?? 0;
          final percentage = totalReviews > 0
              ? (count / totalReviews) * 100
              : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '$rating ★',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      rating >= 4
                          ? Colors.green
                          : rating >= 3
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search reviews...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadReviews(refresh: true);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) => _searchReviews(),
            ),
            const SizedBox(height: 12.0),

            // Filters
            Row(
              children: [
                Expanded(child: _buildSortDropdown()),
                const SizedBox(width: 12.0),
                Expanded(child: _buildRatingFilterDropdown()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSortBy,
      decoration: const InputDecoration(
        labelText: 'Sort by',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'date', child: Text('Date')),
        DropdownMenuItem(value: 'rating', child: Text('Rating')),
        DropdownMenuItem(value: 'helpful', child: Text('Most Helpful')),
      ],
      onChanged: (value) {
        if (value != null) {
          _onSortChanged(value);
        }
      },
    );
  }

  Widget _buildRatingFilterDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRatingFilter,
      decoration: const InputDecoration(
        labelText: 'Rating',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'All', child: Text('All Ratings')),
        DropdownMenuItem(value: '5', child: Text('5 Stars')),
        DropdownMenuItem(value: '4', child: Text('4+ Stars')),
        DropdownMenuItem(value: '3', child: Text('3+ Stars')),
        DropdownMenuItem(value: '2', child: Text('2+ Stars')),
        DropdownMenuItem(value: '1', child: Text('1+ Stars')),
      ],
      onChanged: (value) {
        if (value != null) {
          _onRatingFilterChanged(value);
        }
      },
    );
  }

  Widget _buildReviewsList() {
    if (_isLoading && _reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16.0),
            Text(
              _error!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            CustomButton(
              onPressed: () => _loadReviews(refresh: true),
              text: 'Retry',
            ),
          ],
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16.0),
            Text(
              'No reviews yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Be the first to review this service provider!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadReviews(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _reviews.length + (_hasMoreReviews ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _reviews.length) {
            return _buildLoadMoreButton();
          }
          return _buildReviewCard(_reviews[index]);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: CustomButton(
          onPressed: _isLoading ? null : () => _loadReviews(),
          text: _isLoading ? 'Loading...' : 'Load More',
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    review.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        review.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (review.isVerified)
                  Icon(Icons.verified, color: Colors.blue[600], size: 20),
              ],
            ),
            const SizedBox(height: 12.0),

            // Rating
            Row(
              children: [
                StarRatingDisplay(rating: review.rating, size: 16.0),
                const SizedBox(width: 8.0),
                Text(
                  review.ratingText,
                  style: TextStyle(
                    color: review.ratingColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Tags
            if (review.tags != null && review.tags!.isNotEmpty)
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: review.tags!
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey[100],
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                    )
                    .toList(),
              ),

            // Comment
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Reply
            if (review.hasReply) ...[
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4.0),
                        Text(
                          'Response from ${review.replyBy ?? 'Provider'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      review.reply!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
