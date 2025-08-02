import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_provider_model.dart';
import '../widgets/verification_badge_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/star_rating_widget.dart';

class ProviderVerificationScreen extends StatefulWidget {
  final ServiceProviderModel provider;

  const ProviderVerificationScreen({Key? key, required this.provider})
    : super(key: key);

  @override
  State<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState extends State<ProviderVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header with provider info and verification badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.provider.profileImage != null
                          ? NetworkImage(widget.provider.profileImage!)
                          : null,
                      child: widget.provider.profileImage == null
                          ? Text(
                              widget.provider.name
                                  .substring(0, 1)
                                  .toUpperCase(),
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
                      onTap: () => _showVerificationDetails(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Trust Score
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trust Score',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              '${_calculateTrustScore()}%',
                              style: TextStyle(
                                fontSize: 18,
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
              ],
            ),
          ),
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue.shade600,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.blue.shade600,
              tabs: const [
                Tab(text: 'Verification'),
                Tab(text: 'Experience'),
                Tab(text: 'Certifications'),
                Tab(text: 'Specializations'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVerificationTab(),
                _buildExperienceTab(),
                _buildCertificationsTab(),
                _buildSpecializationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerificationSection(
            'Background Check',
            Icons.security,
            widget.provider.isBackgroundChecked ? 'Completed' : 'Pending',
            widget.provider.isBackgroundChecked ? Colors.green : Colors.orange,
            widget.provider.isBackgroundChecked
                ? 'Background verification completed on ${_formatDate(widget.provider.updatedAt)}'
                : 'Background check pending',
          ),
          const SizedBox(height: 16),
          _buildVerificationSection(
            'ID Verification',
            Icons.badge,
            widget.provider.isVerified ? 'Verified' : 'Pending',
            widget.provider.isVerified ? Colors.green : Colors.orange,
            widget.provider.isVerified
                ? 'Government ID verified on ${_formatDate(widget.provider.updatedAt)}'
                : 'ID verification pending',
          ),
          const SizedBox(height: 16),
          _buildVerificationSection(
            'Address Verification',
            Icons.location_on,
            widget.provider.address != null ? 'Verified' : 'Pending',
            widget.provider.address != null ? Colors.green : Colors.orange,
            widget.provider.address != null
                ? 'Address verified on ${_formatDate(widget.provider.updatedAt)}'
                : 'Address verification pending',
          ),
          const SizedBox(height: 16),
          _buildVerificationSection(
            'Phone Verification',
            Icons.phone,
            'Verified',
            Colors.green,
            'Phone number verified on ${_formatDate(widget.provider.createdAt)}',
          ),
          const SizedBox(height: 16),
          _buildVerificationSection(
            'Bank Account',
            Icons.account_balance,
            'Verified',
            Colors.green,
            'Bank account verified for payments',
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Report Issue',
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExperienceCard(
            'Total Experience',
            widget.provider.experience ?? 'Not specified',
            Icons.work,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildExperienceCard(
            'Services Completed',
            '${widget.provider.completedBookings} services',
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildExperienceCard(
            'Total Bookings',
            '${widget.provider.totalBookings} bookings',
            Icons.schedule,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildExperienceCard(
            'Completion Rate',
            '${widget.provider.totalBookings > 0 ? (widget.provider.completedBookings / widget.provider.totalBookings * 100).round() : 0}%',
            Icons.trending_up,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          const Text(
            'Service History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildServiceHistoryList(),
        ],
      ),
    );
  }

  Widget _buildCertificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.provider.certifications != null &&
              widget.provider.certifications!.isNotEmpty) ...[
            _buildCertificationCard(widget.provider.certifications!),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'No certifications uploaded yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          CustomButton(
            text: 'Request Certification Upload',
            onPressed: () => _showCertificationRequest(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primary Specializations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.provider.specializations
                .map((spec) => _buildSpecializationChip(spec))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Service Areas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildServiceAreasList(),
          const SizedBox(height: 24),
          const Text(
            'Availability',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildAvailabilitySchedule(),
        ],
      ),
    );
  }

  Widget _buildVerificationSection(
    String title,
    IconData icon,
    String status,
    Color color,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationCard(String certification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              certification,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationChip(String specialization) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        specialization,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildServiceAreasList() {
    final serviceAreas = [
      if (widget.provider.city != null) widget.provider.city!,
      if (widget.provider.state != null) widget.provider.state!,
    ];

    if (serviceAreas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No service areas specified',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: serviceAreas
          .map(
            (area) => ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: Text(area),
              trailing: const Icon(Icons.check, color: Colors.green),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAvailabilitySchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildAvailabilityRow('Monday - Friday', '8:00 AM - 8:00 PM'),
          const Divider(),
          _buildAvailabilityRow('Saturday', '9:00 AM - 6:00 PM'),
          const Divider(),
          _buildAvailabilityRow('Sunday', '10:00 AM - 4:00 PM'),
        ],
      ),
    );
  }

  Widget _buildAvailabilityRow(String day, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(time, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildServiceHistoryList() {
    // Mock service history data
    final serviceHistory = [
      {'service': 'Electrical Repair', 'date': '2024-01-15', 'rating': 5.0},
      {'service': 'Plumbing Installation', 'date': '2024-01-10', 'rating': 4.5},
      {'service': 'AC Maintenance', 'date': '2024-01-05', 'rating': 5.0},
    ];

    return Column(
      children: serviceHistory
          .map(
            (service) => ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: Text(service['service'] as String),
              subtitle: Text(
                _formatDate(DateTime.parse(service['date'] as String)),
              ),
              trailing: StarRatingWidget(
                initialRating: service['rating'] as double,
                size: 16,
              ),
            ),
          )
          .toList(),
    );
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not verified';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showVerificationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerificationBadgeWidget(
              level: _getVerificationLevel(),
              badgeText: _getVerificationText(),
              showDetails: false,
            ),
            const SizedBox(height: 16),
            Text(
              _getVerificationLevel().getLevelDescription(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Requirements:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_getVerificationLevel().getLevelRequirements()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Verification Issue'),
        content: const Text(
          'If you notice any issues with this provider\'s verification, please report it to our support team.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted successfully')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showCertificationRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Certification'),
        content: const Text(
          'We\'ll send a request to the provider to upload their certifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certification request sent')),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
