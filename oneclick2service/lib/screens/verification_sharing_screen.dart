import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/service_provider_model.dart';
import '../widgets/verification_badge_widget.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/custom_button.dart';

class VerificationSharingScreen extends StatefulWidget {
  final ServiceProviderModel provider;

  const VerificationSharingScreen({Key? key, required this.provider})
    : super(key: key);

  @override
  State<VerificationSharingScreen> createState() =>
      _VerificationSharingScreenState();
}

class _VerificationSharingScreenState extends State<VerificationSharingScreen> {
  String _selectedPlatform = 'whatsapp';
  String _customMessage = '';

  @override
  void initState() {
    super.initState();
    _customMessage = _generateDefaultMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            _buildPreviewCard(),
            const SizedBox(height: 24),
            // Sharing options
            _buildSharingOptions(),
            const SizedBox(height: 24),
            // Custom message
            _buildCustomMessageSection(),
            const SizedBox(height: 24),
            // Share button
            CustomButton(
              text: 'Share Verification',
              onPressed: () => _shareVerification(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Provider info
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: widget.provider.profileImage != null
                    ? NetworkImage(widget.provider.profileImage!)
                    : null,
                child: widget.provider.profileImage == null
                    ? Text(
                        widget.provider.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.provider.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.provider.serviceCategories.isNotEmpty
                          ? widget.provider.serviceCategories.first
                          : 'Service Provider',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StarRatingWidget(
                          initialRating: widget.provider.rating,
                          size: 16,
                          readOnly: true,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.provider.rating} (${widget.provider.totalReviews} reviews)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              VerificationBadgeWidget(
                level: _getVerificationLevel(),
                badgeText: _getVerificationText(),
                showDetails: false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Trust score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trust Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        '${_calculateTrustScore()}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: _calculateTrustScore() / 100,
                  backgroundColor: Colors.blue.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Verification details
          _buildVerificationDetails(),
        ],
      ),
    );
  }

  Widget _buildVerificationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildVerificationItem(
          'Background Check',
          widget.provider.isBackgroundChecked ? 'Completed' : 'Pending',
          widget.provider.isBackgroundChecked
              ? Icons.check_circle
              : Icons.pending,
          widget.provider.isBackgroundChecked ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildVerificationItem(
          'ID Verification',
          widget.provider.isVerified ? 'Verified' : 'Pending',
          widget.provider.isVerified ? Icons.check_circle : Icons.pending,
          widget.provider.isVerified ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildVerificationItem(
          'Experience',
          widget.provider.experience ?? 'Not specified',
          Icons.work,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildVerificationItem(
          'Completed Services',
          '${widget.provider.completedBookings} services',
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildVerificationItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSharingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share via',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSharingOption(
              'whatsapp',
              'WhatsApp',
              Icons.chat,
              Colors.green,
            ),
            _buildSharingOption(
              'telegram',
              'Telegram',
              Icons.send,
              Colors.blue,
            ),
            _buildSharingOption('sms', 'SMS', Icons.message, Colors.orange),
            _buildSharingOption('email', 'Email', Icons.email, Colors.red),
            _buildSharingOption('copy', 'Copy Link', Icons.copy, Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildSharingOption(
    String platform,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPlatform == platform;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlatform = platform;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Message',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add your custom message...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          controller: TextEditingController(text: _customMessage),
          onChanged: (value) {
            setState(() {
              _customMessage = value;
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _customMessage = _generateDefaultMessage();
                });
              },
              child: const Text('Reset to Default'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _copyToClipboard(),
              child: const Text('Copy Message'),
            ),
          ],
        ),
      ],
    );
  }

  String _generateDefaultMessage() {
    final verificationLevel = _getVerificationText();
    final trustScore = _calculateTrustScore();

    return '''🔍 Verified Service Provider

${widget.provider.name}
${widget.provider.serviceCategories.isNotEmpty ? widget.provider.serviceCategories.first : 'Service Provider'}

⭐ Rating: ${widget.provider.rating}/5 (${widget.provider.totalReviews} reviews)
🛡️ Trust Score: $trustScore%
✅ Verification Level: $verificationLevel

Book trusted services on One Click 2 Service!''';
  }

  VerificationLevel _getVerificationLevel() {
    if (widget.provider.rating >= 4.8 &&
        widget.provider.completedBookings >= 100) {
      return VerificationLevel.expert;
    } else if (widget.provider.rating >= 4.5 &&
        widget.provider.completedBookings >= 50) {
      return VerificationLevel.premium;
    } else if (widget.provider.isBackgroundChecked) {
      return VerificationLevel.verified;
    } else {
      return VerificationLevel.basic;
    }
  }

  String _getVerificationText() {
    switch (_getVerificationLevel()) {
      case VerificationLevel.basic:
        return 'Basic';
      case VerificationLevel.verified:
        return 'Verified';
      case VerificationLevel.premium:
        return 'Premium';
      case VerificationLevel.expert:
        return 'Expert';
    }
  }

  int _calculateTrustScore() {
    int score = 0;

    // Base score for basic verification
    score += 20;

    // Additional points for each verification step
    if (widget.provider.isBackgroundChecked) score += 20;
    if (widget.provider.isVerified) score += 15;
    if (widget.provider.address != null) score += 15;
    if (widget.provider.phoneNumber.isNotEmpty) score += 10;

    // Points for experience and ratings
    if (widget.provider.experience != null &&
        widget.provider.experience!.contains('3'))
      score += 10;
    if (widget.provider.rating >= 4.5) score += 10;

    return score.clamp(0, 100);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _customMessage));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  void _shareVerification() {
    String shareUrl = '';
    String shareText = _customMessage;

    switch (_selectedPlatform) {
      case 'whatsapp':
        shareUrl = 'whatsapp://send?text=${Uri.encodeComponent(shareText)}';
        break;
      case 'telegram':
        shareUrl =
            'https://t.me/share/url?url=${Uri.encodeComponent('https://oneclick2service.com')}&text=${Uri.encodeComponent(shareText)}';
        break;
      case 'sms':
        shareUrl = 'sms:?body=${Uri.encodeComponent(shareText)}';
        break;
      case 'email':
        shareUrl =
            'mailto:?subject=Verified Service Provider&body=${Uri.encodeComponent(shareText)}';
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: shareText));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification details copied to clipboard'),
          ),
        );
        return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing via ${_getPlatformName()}'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            // In a real app, you would use url_launcher to open the URL
            // For now, just show a message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening sharing app...')),
            );
          },
        ),
      ),
    );
  }

  String _getPlatformName() {
    switch (_selectedPlatform) {
      case 'whatsapp':
        return 'WhatsApp';
      case 'telegram':
        return 'Telegram';
      case 'sms':
        return 'SMS';
      case 'email':
        return 'Email';
      case 'copy':
        return 'Clipboard';
      default:
        return 'App';
    }
  }
}
