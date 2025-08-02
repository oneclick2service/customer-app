import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../models/review_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../constants/app_constants.dart';

class ReviewModerationScreen extends StatefulWidget {
  final String providerId;

  const ReviewModerationScreen({Key? key, required this.providerId})
    : super(key: key);

  @override
  State<ReviewModerationScreen> createState() => _ReviewModerationScreenState();
}

class _ReviewModerationScreenState extends State<ReviewModerationScreen> {
  String _selectedFilter = 'all';
  String _selectedSort = 'recent';
  bool _showReportedOnly = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = [
    'all',
    '5_star',
    '4_star',
    '3_star',
    '2_star',
    '1_star',
  ];

  final List<String> _sortOptions = [
    'recent',
    'oldest',
    'highest_rating',
    'lowest_rating',
    'most_helpful',
    'least_helpful',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Moderation'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, reviewProvider, child) {
                return FutureBuilder<List<Review>>(
                  future: reviewProvider.getFilteredReviews(
                    providerId: widget.providerId,
                    filter: _selectedFilter,
                    sort: _selectedSort,
                    searchQuery: _searchController.text,
                    reportedOnly: _showReportedOnly,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading reviews: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final reviews = snapshot.data ?? [];

                    if (reviews.isEmpty) {
                      return const Center(
                        child: Text(
                          'No reviews found with current filters',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return _buildReviewCard(review, reviewProvider);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          CustomTextField(
            controller: _searchController,
            hintText: 'Search reviews...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Filter options
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Rating',
                    border: OutlineInputBorder(),
                  ),
                  items: _filterOptions.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(_getFilterDisplayName(filter)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSort,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    border: OutlineInputBorder(),
                  ),
                  items: _sortOptions.map((sort) {
                    return DropdownMenuItem(
                      value: sort,
                      child: Text(_getSortDisplayName(sort)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reported reviews toggle
          Row(
            children: [
              Checkbox(
                value: _showReportedOnly,
                onChanged: (value) {
                  setState(() {
                    _showReportedOnly = value!;
                  });
                },
              ),
              const Text('Show reported reviews only'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review, ReviewProvider reviewProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review.userProfileImage != null
                      ? NetworkImage(review.userProfileImage!)
                      : null,
                  child: review.userProfileImage == null
                      ? Text(review.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (review.isReported)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'REPORTED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${review.rating}.0',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Review text
            if (review.comment.isNotEmpty) ...[
              Text(review.comment, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
            ],

            // Aspect ratings
            if (review.aspectRatings.isNotEmpty) ...[
              _buildAspectRatings(review.aspectRatings),
              const SizedBox(height: 8),
            ],

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        review.isHelpful
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: review.isHelpful
                            ? AppConstants.primaryColor
                            : null,
                      ),
                      onPressed: () {
                        reviewProvider.toggleHelpful(review.id);
                      },
                    ),
                    Text('${review.helpfulCount}'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.report),
                      onPressed: () => _showReportDialog(review),
                    ),
                  ],
                ),
                if (review.isReported)
                  Row(
                    children: [
                      CustomButton(
                        text: 'Approve',
                        onPressed: () => _approveReview(review.id),
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomButton(
                        text: 'Remove',
                        onPressed: () => _removeReview(review.id),
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectRatings(Map<String, int> aspectRatings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: aspectRatings.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              ...List.generate(5, (index) {
                return Icon(
                  index < entry.value ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 12,
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showReportDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this review?'),
            const SizedBox(height: 16),
            _buildReportOption('Inappropriate content'),
            _buildReportOption('Spam or fake review'),
            _buildReportOption('Offensive language'),
            _buildReportOption('Other'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Submit report
              context.read<ReviewProvider>().reportReview(review.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review reported successfully')),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String reason) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Radio<String>(value: reason, groupValue: null, onChanged: (value) {}),
          Text(reason),
        ],
      ),
    );
  }

  void _approveReview(String reviewId) {
    context.read<ReviewProvider>().approveReview(reviewId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Review approved')));
  }

  void _removeReview(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Review'),
        content: const Text(
          'Are you sure you want to remove this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ReviewProvider>().removeReview(reviewId);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Review removed')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Ratings';
      case '5_star':
        return '5 Stars';
      case '4_star':
        return '4 Stars';
      case '3_star':
        return '3 Stars';
      case '2_star':
        return '2 Stars';
      case '1_star':
        return '1 Star';
      default:
        return filter;
    }
  }

  String _getSortDisplayName(String sort) {
    switch (sort) {
      case 'recent':
        return 'Most Recent';
      case 'oldest':
        return 'Oldest First';
      case 'highest_rating':
        return 'Highest Rating';
      case 'lowest_rating':
        return 'Lowest Rating';
      case 'most_helpful':
        return 'Most Helpful';
      case 'least_helpful':
        return 'Least Helpful';
      default:
        return sort;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
