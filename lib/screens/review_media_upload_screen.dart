import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/custom_button.dart';
import '../models/booking_model.dart';

class ReviewMediaUploadScreen extends StatefulWidget {
  final BookingModel booking;

  const ReviewMediaUploadScreen({Key? key, required this.booking})
    : super(key: key);

  @override
  State<ReviewMediaUploadScreen> createState() =>
      _ReviewMediaUploadScreenState();
}

class _ReviewMediaUploadScreenState extends State<ReviewMediaUploadScreen> {
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Media to Review'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedImages.isNotEmpty || _selectedVideos.isNotEmpty)
            TextButton(
              onPressed: _isUploading ? null : _uploadMedia,
              child: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Upload'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Service Details
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.home_repair_service,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking.serviceType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Provider: ${widget.booking.serviceProviderId ?? 'Not Assigned'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Media Upload Options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upload Options
                  const Text(
                    'Add Photos & Videos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Upload Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadButton(
                          icon: Icons.photo_camera,
                          title: 'Add Photos',
                          subtitle: 'Take or select photos',
                          onTap: _addPhotos,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUploadButton(
                          icon: Icons.videocam,
                          title: 'Add Videos',
                          subtitle: 'Record or select videos',
                          onTap: _addVideos,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Selected Media Preview
                  if (_selectedImages.isNotEmpty ||
                      _selectedVideos.isNotEmpty) ...[
                    const Text(
                      'Selected Media',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Images Grid
                    if (_selectedImages.isNotEmpty) ...[
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return _buildMediaPreview(
                            file: _selectedImages[index],
                            isVideo: false,
                            onRemove: () => _removeImage(index),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Videos Grid
                    if (_selectedVideos.isNotEmpty) ...[
                      const Text(
                        'Videos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _selectedVideos.length,
                        itemBuilder: (context, index) {
                          return _buildMediaPreview(
                            file: _selectedVideos[index],
                            isVideo: true,
                            onRemove: () => _removeVideo(index),
                          );
                        },
                      ),
                    ],
                  ],

                  const SizedBox(height: 24),

                  // Guidelines
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Media Guidelines',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• Photos: Max 5 images, 5MB each\n'
                            '• Videos: Max 2 videos, 50MB each\n'
                            '• Supported formats: JPG, PNG, MP4\n'
                            '• Keep content relevant to the service\n'
                            '• Avoid personal information in media',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Upload Progress
                  if (_isUploading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text(
                      'Uploading media...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          if (_selectedImages.isNotEmpty || _selectedVideos.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: _isUploading ? null : _clearAll,
                      text: 'Clear All',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      onPressed: _isUploading ? null : _uploadMedia,
                      text: _isUploading ? 'Uploading...' : 'Upload Media',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview({
    required File file,
    required bool isVideo,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: isVideo
                  ? Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    )
                  : Image.file(file, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        if (isVideo)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  void _addPhotos() {
    // Simulate photo selection
    setState(() {
      _isLoading = true;
    });

    // Simulate loading photos
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        // In a real app, this would be actual file selection
        // For demo purposes, we'll just show a message
      });
      _showSnackBar('Photo selection would open here');
    });
  }

  void _addVideos() {
    // Simulate video selection
    setState(() {
      _isLoading = true;
    });

    // Simulate loading videos
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        // In a real app, this would be actual file selection
        // For demo purposes, we'll just show a message
      });
      _showSnackBar('Video selection would open here');
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedImages.clear();
      _selectedVideos.clear();
    });
  }

  void _uploadMedia() async {
    if (_selectedImages.isEmpty && _selectedVideos.isEmpty) {
      _showSnackBar('Please select at least one photo or video');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Simulate upload process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isUploading = false;
    });

    _showUploadSuccessDialog();
  }

  void _showUploadSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Media Uploaded'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photos uploaded: ${_selectedImages.length}'),
            const SizedBox(height: 4),
            Text('Videos uploaded: ${_selectedVideos.length}'),
            const SizedBox(height: 8),
            const Text(
              'Your media has been successfully uploaded and will be included in your review.',
            ),
          ],
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
