import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class CustomRequestScreen extends StatefulWidget {
  const CustomRequestScreen({Key? key}) : super(key: key);

  @override
  State<CustomRequestScreen> createState() => _CustomRequestScreenState();
}

class _CustomRequestScreenState extends State<CustomRequestScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isRecordingAudio = false;
  bool _isRecordingVideo = false;
  List<String> _uploadedPhotos = [];
  String? _audioFilePath;
  String? _videoFilePath;
  double _estimatedPrice = 0.0;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _startAudioRecording() {
    setState(() {
      _isRecordingAudio = true;
    });
    // TODO: Implement actual audio recording
    // This would integrate with a recording package like record_mp4
  }

  void _stopAudioRecording() {
    setState(() {
      _isRecordingAudio = false;
      _audioFilePath = 'audio_recording.mp3'; // Placeholder
    });
    _calculateEstimatedPrice();
  }

  void _startVideoRecording() {
    setState(() {
      _isRecordingVideo = true;
    });
    // TODO: Implement actual video recording
    // This would integrate with camera package
  }

  void _stopVideoRecording() {
    setState(() {
      _isRecordingVideo = false;
      _videoFilePath = 'video_recording.mp4'; // Placeholder
    });
    _calculateEstimatedPrice();
  }

  void _addPhoto() {
    // TODO: Implement photo picker
    // This would integrate with image_picker package
    setState(() {
      _uploadedPhotos.add('photo_${_uploadedPhotos.length + 1}.jpg');
    });
    _calculateEstimatedPrice();
  }

  void _removePhoto(int index) {
    setState(() {
      _uploadedPhotos.removeAt(index);
    });
    _calculateEstimatedPrice();
  }

  void _calculateEstimatedPrice() {
    double basePrice = 299.0;
    double audioBonus = _audioFilePath != null ? 50.0 : 0.0;
    double videoBonus = _videoFilePath != null ? 100.0 : 0.0;
    double photoBonus = _uploadedPhotos.length * 25.0;
    double descriptionBonus = _descriptionController.text.isNotEmpty
        ? 30.0
        : 0.0;

    setState(() {
      _estimatedPrice =
          basePrice + audioBonus + videoBonus + photoBonus + descriptionBonus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppConstants.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Custom Service Request',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description Input
                        const Text(
                          'Describe your service requirement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _descriptionController,
                          hintText: 'Describe what service you need...',
                          maxLines: 4,
                          onChanged: (value) => _calculateEstimatedPrice(),
                        ),
                        const SizedBox(height: 24),

                        // Audio Recording Section
                        _buildSection(
                          title: 'Voice Description',
                          subtitle: 'Record audio to explain your requirement',
                          icon: Icons.mic,
                          child: Column(
                            children: [
                              if (_audioFilePath != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.audiotrack,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Audio recorded'),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _audioFilePath = null;
                                          });
                                          _calculateEstimatedPrice();
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                CustomButton(
                                  text: _isRecordingAudio
                                      ? 'Recording...'
                                      : 'Record Audio',
                                  onPressed: _isRecordingAudio
                                      ? _stopAudioRecording
                                      : _startAudioRecording,
                                  backgroundColor: _isRecordingAudio
                                      ? Colors.red
                                      : AppConstants.primaryColor,
                                  icon: _isRecordingAudio
                                      ? Icons.stop
                                      : Icons.mic,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Video Recording Section
                        _buildSection(
                          title: 'Video Recording',
                          subtitle: 'Record video to show the issue',
                          icon: Icons.videocam,
                          child: Column(
                            children: [
                              if (_videoFilePath != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.videocam,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Video recorded'),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _videoFilePath = null;
                                          });
                                          _calculateEstimatedPrice();
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                CustomButton(
                                  text: _isRecordingVideo
                                      ? 'Recording...'
                                      : 'Record Video',
                                  onPressed: _isRecordingVideo
                                      ? _stopVideoRecording
                                      : _startVideoRecording,
                                  backgroundColor: _isRecordingVideo
                                      ? Colors.red
                                      : AppConstants.primaryColor,
                                  icon: _isRecordingVideo
                                      ? Icons.stop
                                      : Icons.videocam,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Photo Upload Section
                        _buildSection(
                          title: 'Photo Upload',
                          subtitle: 'Add photos to show the problem',
                          icon: Icons.photo_camera,
                          child: Column(
                            children: [
                              if (_uploadedPhotos.isNotEmpty)
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemCount: _uploadedPhotos.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == _uploadedPhotos.length) {
                                      return GestureDetector(
                                        onTap: _addPhoto,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[400]!,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add_a_photo,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    }
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.photo,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removePhoto(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              else
                                CustomButton(
                                  text: 'Add Photos',
                                  onPressed: _addPhoto,
                                  backgroundColor: AppConstants.primaryColor,
                                  icon: Icons.photo_camera,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Estimated Price
                        if (_estimatedPrice > 0)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Estimated Price:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₹${_estimatedPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 30),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Save Draft',
                                onPressed: () {
                                  // TODO: Save draft functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Draft saved'),
                                    ),
                                  );
                                },
                                backgroundColor: Colors.grey[200],
                                textColor: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Submit Request',
                                onPressed: _estimatedPrice > 0
                                    ? () {
                                        // Navigate to provider selection
                                        Navigator.pushNamed(
                                          context,
                                          '/provider-selection',
                                          arguments: {
                                            'isCustomRequest': true,
                                            'description':
                                                _descriptionController.text,
                                            'estimatedPrice': _estimatedPrice,
                                            'audioFile': _audioFilePath,
                                            'videoFile': _videoFilePath,
                                            'photos': _uploadedPhotos,
                                          },
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppConstants.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
