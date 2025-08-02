import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/star_rating_widget.dart';
import '../models/booking_model.dart';

class ReviewEditScreen extends StatefulWidget {
  final BookingModel booking;
  final Map<String, dynamic> existingReview;

  const ReviewEditScreen({
    Key? key,
    required this.booking,
    required this.existingReview,
  }) : super(key: key);

  @override
  State<ReviewEditScreen> createState() => _ReviewEditScreenState();
}

class _ReviewEditScreenState extends State<ReviewEditScreen> {
  final TextEditingController _reviewTextController = TextEditingController();
  double _rating = 0.0;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _showDeleteConfirmation = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview['rating']?.toDouble() ?? 0.0;
    _reviewTextController.text = widget.existingReview['text'] ?? '';
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Review'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showDeleteConfirmation ? null : _showDeleteDialog,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Review',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service:'),
                        Text(widget.booking.serviceType),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Provider:'),
                        Text(
                          widget.booking.serviceProviderId ?? 'Not Assigned',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service Date:'),
                        Text(
                          '${widget.booking.scheduledDate.day}/${widget.booking.scheduledDate.month}/${widget.booking.scheduledDate.year}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current Review Status
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Current Review Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Rating: '),
                        StarRatingWidget(
                          initialRating: _rating,
                          onRatingChanged: (rating) {
                            setState(() {
                              _rating = rating;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${_getReviewStatus()}'),
                    const SizedBox(height: 8),
                    Text(
                      'Last Updated: ${_formatDate(widget.existingReview['updatedAt'] ?? DateTime.now())}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Edit Review Form
            const Text(
              'Edit Your Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Rating
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: StarRatingWidget(
                        initialRating: _rating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Review Text
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review Text',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _reviewTextController,
                      hintText: 'Share your experience with this service...',
                      maxLines: 5,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_reviewTextController.text.length}/500 characters',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Edit History
            if (widget.existingReview['editHistory'] != null) ...[
              const Text(
                'Edit History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Previous Versions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildEditHistory(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Guidelines
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Review Guidelines',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Be honest and constructive\n'
                      '• Avoid personal attacks\n'
                      '• Focus on the service quality\n'
                      '• Keep reviews relevant and helpful\n'
                      '• Reviews are moderated for quality',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    text: _isSaving ? 'Saving...' : 'Save Changes',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: _isLoading ? null : _cancelEdit,
                    text: 'Cancel',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Delete Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _showDeleteConfirmation ? null : _showDeleteDialog,
                text: 'Delete Review',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEditHistory() {
    final editHistory = widget.existingReview['editHistory'] as List? ?? [];

    if (editHistory.isEmpty) {
      return [
        Text(
          'No previous edits',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ];
    }

    return editHistory.map<Widget>((edit) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edited on ${_formatDate(edit['timestamp'])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Rating: ${edit['rating']}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(edit['text'] ?? '', style: const TextStyle(fontSize: 14)),
          ],
        ),
      );
    }).toList();
  }

  String _getReviewStatus() {
    final status = widget.existingReview['status'] ?? 'published';
    switch (status) {
      case 'published':
        return 'Published';
      case 'pending':
        return 'Pending Review';
      case 'rejected':
        return 'Rejected';
      case 'edited':
        return 'Recently Edited';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _saveChanges() async {
    if (_rating == 0) {
      _showSnackBar('Please provide a rating');
      return;
    }

    if (_reviewTextController.text.trim().isEmpty) {
      _showSnackBar('Please write a review');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulate saving changes
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSaving = false;
    });

    _showSaveSuccessDialog();
  }

  void _cancelEdit() {
    Navigator.of(context).pop();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteReview();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteReview() async {
    setState(() {
      _showDeleteConfirmation = true;
    });

    // Simulate deletion process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _showDeleteConfirmation = false;
    });

    _showDeleteSuccessDialog();
  }

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Review Updated'),
          ],
        ),
        content: const Text(
          'Your review has been successfully updated and will be visible to others.',
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

  void _showDeleteSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Review Deleted'),
          ],
        ),
        content: const Text('Your review has been successfully deleted.'),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
