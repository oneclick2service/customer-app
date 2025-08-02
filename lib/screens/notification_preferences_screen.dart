import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../services/notification_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final NotificationService _notificationService = NotificationService();

  // Notification preferences
  bool _bookingUpdates = true;
  bool _providerMessages = true;
  bool _etaUpdates = true;
  bool _paymentConfirmations = true;
  bool _reviewReminders = true;
  bool _promotionalNotifications = false;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Get current user ID from auth provider
      final String userId = 'current_user_id'; // Replace with actual user ID

      final preferences = await _notificationService
          .getUserNotificationPreferences(userId);

      setState(() {
        _bookingUpdates = preferences['booking_updates'] ?? true;
        _providerMessages = preferences['provider_messages'] ?? true;
        _etaUpdates = preferences['eta_updates'] ?? true;
        _paymentConfirmations = preferences['payment_confirmations'] ?? true;
        _reviewReminders = preferences['review_reminders'] ?? true;
        _promotionalNotifications =
            preferences['promotional_notifications'] ?? false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load notification preferences: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationPreferences() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Get current user ID from auth provider
      final String userId = 'current_user_id'; // Replace with actual user ID

      final preferences = {
        'booking_updates': _bookingUpdates,
        'provider_messages': _providerMessages,
        'eta_updates': _etaUpdates,
        'payment_confirmations': _paymentConfirmations,
        'review_reminders': _reviewReminders,
        'promotional_notifications': _promotionalNotifications,
      };

      await _notificationService.updateUserNotificationPreferences(
        userId,
        preferences,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save notification preferences: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: AppConstants.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage Your Notifications',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose which notifications you want to receive',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error message
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Notification preferences
                  _buildNotificationSection(
                    title: 'Booking Updates',
                    subtitle:
                        'Get notified about booking confirmations, status changes, and cancellations',
                    icon: Icons.confirmation_number,
                    value: _bookingUpdates,
                    onChanged: (value) =>
                        setState(() => _bookingUpdates = value),
                  ),

                  _buildNotificationSection(
                    title: 'Provider Messages',
                    subtitle:
                        'Receive notifications when service providers send you messages',
                    icon: Icons.message,
                    value: _providerMessages,
                    onChanged: (value) =>
                        setState(() => _providerMessages = value),
                  ),

                  _buildNotificationSection(
                    title: 'ETA Updates',
                    subtitle: 'Get real-time updates on provider arrival time',
                    icon: Icons.access_time,
                    value: _etaUpdates,
                    onChanged: (value) => setState(() => _etaUpdates = value),
                  ),

                  _buildNotificationSection(
                    title: 'Payment Confirmations',
                    subtitle:
                        'Receive notifications for payment confirmations and receipts',
                    icon: Icons.payment,
                    value: _paymentConfirmations,
                    onChanged: (value) =>
                        setState(() => _paymentConfirmations = value),
                  ),

                  _buildNotificationSection(
                    title: 'Review Reminders',
                    subtitle:
                        'Get reminded to rate and review your service experience',
                    icon: Icons.star,
                    value: _reviewReminders,
                    onChanged: (value) =>
                        setState(() => _reviewReminders = value),
                  ),

                  const SizedBox(height: 16),

                  // Promotional notifications
                  _buildNotificationSection(
                    title: 'Promotional Notifications',
                    subtitle:
                        'Receive offers, discounts, and promotional messages',
                    icon: Icons.local_offer,
                    value: _promotionalNotifications,
                    onChanged: (value) =>
                        setState(() => _promotionalNotifications = value),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Save Preferences',
                          onPressed: _isLoading
                              ? null
                              : _saveNotificationPreferences,
                          backgroundColor: AppConstants.primaryColor,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Test Notifications',
                          onPressed: _isLoading ? null : _testNotifications,
                          backgroundColor: Colors.grey[300]!,
                          textColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Clear all notifications
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Clear All Notifications',
                      onPressed: _isLoading ? null : _clearAllNotifications,
                      backgroundColor: Colors.red[50]!,
                      textColor: Colors.red[700]!,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Information section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Notification Information',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Notifications are delivered in real-time via Supabase\n'
                          '• You can change these settings anytime\n'
                          '• Critical booking updates cannot be disabled\n'
                          '• Notifications work even when the app is closed',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blue[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Future<void> _testNotifications() async {
    try {
      // Test booking status notification
      await _notificationService.sendBookingStatusNotification(
        userId: 'test_user',
        bookingId: 'test_booking_123',
        status: 'confirmed',
      );

      // Test chat notification
      await _notificationService.sendChatNotification(
        userId: 'test_user',
        senderName: 'Test Provider',
        message: 'This is a test notification message',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notifications sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
