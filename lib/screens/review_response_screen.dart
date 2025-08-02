import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../providers/review_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../constants/app_constants.dart';

class ReviewResponseScreen extends StatefulWidget {
  final Review review;

  const ReviewResponseScreen({Key? key, required this.review})
    : super(key: key);

  @override
  State<ReviewResponseScreen> createState() => _ReviewResponseScreenState();
}

class _ReviewResponseScreenState extends State<ReviewResponseScreen> {
  final TextEditingController _responseController = TextEditingController();
  final List<String> _attachedFiles = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing response if available
    if (widget.review.providerResponse != null) {
      _responseController.text = widget.review.providerResponse!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respond to Review'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewCard(),
            const SizedBox(height: 24),
            _buildResponseSection(),
            const SizedBox(height: 24),
            _buildAttachmentSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.review.userProfileImage != null
                      ? NetworkImage(widget.review.userProfileImage!)
                      : null,
                  child: widget.review.userProfileImage == null
                      ? Text(widget.review.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(widget.review.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
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
                    index < widget.review.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${widget.review.rating}.0',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Review text
            if (widget.review.comment.isNotEmpty) ...[
              Text(widget.review.comment, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
            ],

            // Aspect ratings
            if (widget.review.aspectRatings.isNotEmpty) ...[
              _buildAspectRatings(widget.review.aspectRatings),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Response',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Respond professionally to address the customer\'s feedback. Your response will be visible to all customers.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _responseController,
          hintText: 'Write your response here...',
          maxLines: 6,
          maxLength: 500,
        ),
        const SizedBox(height: 8),
        Text(
          '${_responseController.text.length}/500 characters',
          style: TextStyle(
            fontSize: 12,
            color: _responseController.text.length > 450
                ? Colors.orange
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add photos or videos to support your response',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        // Attachment buttons
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Add Photo',
                onPressed: _addPhoto,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                icon: Icons.photo_camera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Add Video',
                onPressed: _addVideo,
                backgroundColor: Colors.purple,
                textColor: Colors.white,
                icon: Icons.videocam,
              ),
            ),
          ],
        ),

        // Attached files list
        if (_attachedFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Attached Files:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._attachedFiles.map((file) => _buildAttachmentItem(file)),
        ],
      ],
    );
  }

  Widget _buildAttachmentItem(String fileName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            fileName.toLowerCase().contains('.mp4') ||
                    fileName.toLowerCase().contains('.mov')
                ? Icons.videocam
                : Icons.photo,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(fileName, style: const TextStyle(fontSize: 14))),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _removeAttachment(fileName),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isSubmitting ? 'Submitting...' : 'Submit Response',
        onPressed: _isSubmitting ? null : _submitResponse,
        backgroundColor: AppConstants.primaryColor,
        textColor: Colors.white,
        isLoading: _isSubmitting,
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

  void _addPhoto() async {
    // Simulate photo selection
    setState(() {
      _attachedFiles.add('photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo added successfully'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addVideo() async {
    // Simulate video selection
    setState(() {
      _attachedFiles.add('video_${DateTime.now().millisecondsSinceEpoch}.mp4');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video added successfully'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeAttachment(String fileName) {
    setState(() {
      _attachedFiles.remove(fileName);
    });
  }

  void _submitResponse() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a response'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create updated review with response
      final updatedReview = widget.review.copyWith(
        providerResponse: _responseController.text.trim(),
        providerResponseDate: DateTime.now(),
        providerResponseAttachments: _attachedFiles,
      );

      // Submit response through provider
      final success = await context.read<ReviewProvider>().updateReview(
        updatedReview,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Response submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit response. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
