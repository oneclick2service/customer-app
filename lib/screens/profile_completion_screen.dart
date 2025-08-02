import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  UserModel? _currentUser;
  double _completionPercentage = 0.0;
  List<String> _missingFields = [];
  List<String> _completedFields = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // TODO: Load user data from provider
    setState(() {
      _currentUser = UserModel(
        id: 'user1',
        phoneNumber: '+91 9876543210',
        name: 'John Doe',
        email: 'john.doe@example.com',
        address: '123 Main Street, Vijayawada, Andhra Pradesh',
        profileImage: null,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );
      _calculateCompletion();
      _isLoading = false;
    });
  }

  void _calculateCompletion() {
    if (_currentUser == null) return;

    _completedFields = [];
    _missingFields = [];

    // Check each field
    if (_currentUser!.name?.isNotEmpty == true) {
      _completedFields.add('Full Name');
    } else {
      _missingFields.add('Full Name');
    }

    if (_currentUser!.email?.isNotEmpty == true) {
      _completedFields.add('Email Address');
    } else {
      _missingFields.add('Email Address');
    }

    if (_currentUser!.address?.isNotEmpty == true) {
      _completedFields.add('Address');
    } else {
      _missingFields.add('Address');
    }

    if (_currentUser!.profileImage != null) {
      _completedFields.add('Profile Photo');
    } else {
      _missingFields.add('Profile Photo');
    }

    // Calculate percentage
    final totalFields = 4; // Total number of profile fields
    final completedCount = _completedFields.length;
    _completionPercentage = (completedCount / totalFields) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Completion'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompletionHeader(),
                  const SizedBox(height: 24),
                  _buildCompletionProgress(),
                  const SizedBox(height: 24),
                  _buildMissingFieldsSection(),
                  const SizedBox(height: 24),
                  _buildCompletedFieldsSection(),
                  const SizedBox(height: 24),
                  _buildRemindersSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCompletionHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Complete Your Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A complete profile helps us provide better service and faster booking',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionProgress() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Completion',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_completionPercentage.round()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _completionPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _completionPercentage >= 100
                    ? Colors.green
                    : _completionPercentage >= 75
                    ? Colors.orange
                    : AppConstants.primaryColor,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Text(
              _getCompletionMessage(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getCompletionMessage() {
    if (_completionPercentage >= 100) {
      return '🎉 Your profile is complete! You\'re all set for the best experience.';
    } else if (_completionPercentage >= 75) {
      return 'Almost there! Complete the remaining fields for a full profile.';
    } else if (_completionPercentage >= 50) {
      return 'Good progress! Keep going to unlock all features.';
    } else {
      return 'Let\'s get started! Complete your profile to enjoy all features.';
    }
  }

  Widget _buildMissingFieldsSection() {
    if (_missingFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Missing Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._missingFields.map((field) => _buildMissingFieldItem(field)),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Complete Missing Fields',
              onPressed: () {
                Navigator.pushNamed(context, '/profile-management');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingFieldItem(String field) {
    IconData icon;
    String description;

    switch (field) {
      case 'Full Name':
        icon = Icons.person;
        description = 'Add your full name for personalized service';
        break;
      case 'Email Address':
        icon = Icons.email;
        description = 'Add email for important updates and receipts';
        break;
      case 'Address':
        icon = Icons.location_on;
        description = 'Add your address for faster service booking';
        break;
      case 'Profile Photo':
        icon = Icons.camera_alt;
        description = 'Add a profile photo for better identification';
        break;
      default:
        icon = Icons.info;
        description = 'Complete this field for better service';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.orange[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.orange[400], size: 16),
        ],
      ),
    );
  }

  Widget _buildCompletedFieldsSection() {
    if (_completedFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Completed Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._completedFields.map((field) => _buildCompletedFieldItem(field)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedFieldItem(String field) {
    IconData icon;

    switch (field) {
      case 'Full Name':
        icon = Icons.person;
        break;
      case 'Email Address':
        icon = Icons.email;
        break;
      case 'Address':
        icon = Icons.location_on;
        break;
      case 'Profile Photo':
        icon = Icons.camera_alt;
        break;
      default:
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              field,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
        ],
      ),
    );
  }

  Widget _buildRemindersSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Profile Reminders',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReminderItem(
              'Weekly Profile Check',
              'Get reminded to keep your profile updated',
              Icons.schedule,
              true,
            ),
            const SizedBox(height: 8),
            _buildReminderItem(
              'Booking Reminders',
              'Get notified when your profile is incomplete',
              Icons.notifications_active,
              true,
            ),
            const SizedBox(height: 8),
            _buildReminderItem(
              'Profile Completion Rewards',
              'Earn rewards for completing your profile',
              Icons.card_giftcard,
              false,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Manage Reminders',
              onPressed: () {
                Navigator.pushNamed(context, '/notification-preferences');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(
    String title,
    String description,
    IconData icon,
    bool isEnabled,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled ? Colors.blue[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isEnabled ? Colors.blue[600] : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? Colors.blue[700] : Colors.grey[600],
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isEnabled ? Colors.blue[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // TODO: Implement reminder toggle
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reminder ${value ? 'enabled' : 'disabled'}'),
                ),
              );
            },
            activeColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }
}
