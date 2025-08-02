import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class ReviewNotificationScreen extends StatefulWidget {
  const ReviewNotificationScreen({Key? key}) : super(key: key);

  @override
  State<ReviewNotificationScreen> createState() =>
      _ReviewNotificationScreenState();
}

class _ReviewNotificationScreenState extends State<ReviewNotificationScreen> {
  bool _reviewReminders = true;
  bool _providerResponses = true;
  bool _reviewLikes = true;
  bool _reviewComments = true;
  bool _weeklyDigest = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  final List<Map<String, dynamic>> _notificationHistory = [
    {
      'id': '1',
      'type': 'reminder',
      'title': 'Review Reminder',
      'message': 'Don\'t forget to review your recent service',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'bookingId': 'BK001',
      'serviceType': 'Plumbing Service',
    },
    {
      'id': '2',
      'type': 'response',
      'title': 'Provider Response',
      'message': 'John Smith responded to your review',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'bookingId': 'BK002',
      'serviceType': 'Electrical Service',
    },
    {
      'id': '3',
      'type': 'like',
      'title': 'Review Liked',
      'message': 'Your review received 5 new likes',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'bookingId': 'BK003',
      'serviceType': 'Cleaning Service',
    },
    {
      'id': '4',
      'type': 'comment',
      'title': 'New Comment',
      'message': 'Someone commented on your review',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'bookingId': 'BK004',
      'serviceType': 'Carpentry Service',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review Notifications'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Settings'),
              Tab(text: 'History'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(children: [_buildSettingsTab(), _buildHistoryTab()]),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Types
          const Text(
            'Review Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Review Reminders'),
                  subtitle: const Text(
                    'Get reminded to review completed services',
                  ),
                  value: _reviewReminders,
                  onChanged: (value) {
                    setState(() {
                      _reviewReminders = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Provider Responses'),
                  subtitle: const Text(
                    'When providers respond to your reviews',
                  ),
                  value: _providerResponses,
                  onChanged: (value) {
                    setState(() {
                      _providerResponses = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Review Likes'),
                  subtitle: const Text('When someone likes your review'),
                  value: _reviewLikes,
                  onChanged: (value) {
                    setState(() {
                      _reviewLikes = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Review Comments'),
                  subtitle: const Text('When someone comments on your review'),
                  value: _reviewComments,
                  onChanged: (value) {
                    setState(() {
                      _reviewComments = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Weekly Digest'),
                  subtitle: const Text('Weekly summary of review activity'),
                  value: _weeklyDigest,
                  onChanged: (value) {
                    setState(() {
                      _weeklyDigest = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notification Channels
          const Text(
            'Notification Channels',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications on your device'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive notifications via email'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Receive notifications via SMS'),
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notification Timing
          const Text(
            'Notification Timing',
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
                    'Review Reminder Timing',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You\'ll receive review reminders:\n'
                    '• 24 hours after service completion\n'
                    '• 3 days after service completion\n'
                    '• 7 days after service completion',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: _saveNotificationSettings,
              text: 'Save Settings',
            ),
          ),

          const SizedBox(height: 24),

          // Information Card
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
                        'About Review Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Review reminders help maintain service quality\n'
                    '• Provider responses improve communication\n'
                    '• You can customize notification preferences\n'
                    '• Notifications can be disabled anytime',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final unreadCount = _notificationHistory
        .where((notification) => !notification['isRead'])
        .length;

    return Column(
      children: [
        // Header with unread count
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notification History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Notifications List
        Expanded(
          child: ListView.builder(
            itemCount: _notificationHistory.length,
            itemBuilder: (context, index) {
              final notification = _notificationHistory[index];
              return _buildNotificationTile(notification);
            },
          ),
        ),

        // Clear All Button
        if (_notificationHistory.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _clearAllNotifications,
                text: 'Clear All Notifications',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final isUnread = !notification['isRead'];
    final type = notification['type'];

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'reminder':
        icon = Icons.rate_review;
        iconColor = Colors.orange;
        break;
      case 'response':
        icon = Icons.reply;
        iconColor = Colors.blue;
        break;
      case 'like':
        icon = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        icon = Icons.comment;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isUnread ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            const SizedBox(height: 4),
            Text(
              notification['serviceType'],
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'mark_read') {
              _markAsRead(notification['id']);
            } else if (value == 'delete') {
              _deleteNotification(notification['id']);
            }
          },
          itemBuilder: (context) => [
            if (isUnread)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 8),
                    Text('Mark as Read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
        onTap: () {
          _markAsRead(notification['id']);
          _showNotificationDetails(notification);
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _saveNotificationSettings() {
    // Simulate saving settings
    _showSnackBar('Notification settings saved successfully');
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notificationHistory.firstWhere(
        (n) => n['id'] == notificationId,
      );
      notification['isRead'] = true;
    });
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notificationHistory.removeWhere((n) => n['id'] == notificationId);
    });
    _showSnackBar('Notification deleted');
  }

  void _clearAllNotifications() {
    setState(() {
      _notificationHistory.clear();
    });
    _showSnackBar('All notifications cleared');
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            const SizedBox(height: 8),
            Text('Service: ${notification['serviceType']}'),
            const SizedBox(height: 8),
            Text('Booking ID: ${notification['bookingId']}'),
            const SizedBox(height: 8),
            Text('Time: ${_formatTimestamp(notification['timestamp'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
