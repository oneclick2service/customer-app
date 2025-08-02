import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';

class ReferralSystemScreen extends StatefulWidget {
  const ReferralSystemScreen({Key? key}) : super(key: key);

  @override
  State<ReferralSystemScreen> createState() => _ReferralSystemScreenState();
}

class _ReferralSystemScreenState extends State<ReferralSystemScreen> {
  UserModel? _currentUser;
  String _referralCode = 'JOHN123';
  int _totalReferrals = 5;
  int _successfulReferrals = 3;
  double _totalRewards = 150.0;
  List<Map<String, dynamic>> _referralHistory = [];
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
      _loadReferralHistory();
      _isLoading = false;
    });
  }

  void _loadReferralHistory() {
    // TODO: Load referral history from provider
    _referralHistory = [
      {
        'name': 'Sarah Wilson',
        'phone': '+91 9876543211',
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'reward': 50.0,
      },
      {
        'name': 'Mike Johnson',
        'phone': '+91 9876543212',
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 14)),
        'reward': 50.0,
      },
      {
        'name': 'Emily Brown',
        'phone': '+91 9876543213',
        'status': 'pending',
        'date': DateTime.now().subtract(const Duration(days: 21)),
        'reward': 0.0,
      },
      {
        'name': 'David Lee',
        'phone': '+91 9876543214',
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 28)),
        'reward': 50.0,
      },
      {
        'name': 'Lisa Chen',
        'phone': '+91 9876543215',
        'status': 'pending',
        'date': DateTime.now().subtract(const Duration(days: 35)),
        'reward': 0.0,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Program'),
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
                  _buildReferralHeader(),
                  const SizedBox(height: 24),
                  _buildReferralStats(),
                  const SizedBox(height: 24),
                  _buildReferralCodeSection(),
                  const SizedBox(height: 24),
                  _buildShareOptions(),
                  const SizedBox(height: 24),
                  _buildReferralHistory(),
                  const SizedBox(height: 24),
                  _buildRewardsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildReferralHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.share, size: 48, color: AppConstants.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Invite Friends & Earn Rewards',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Share One Click 2 Service with your friends and earn ₹50 for each successful referral',
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

  Widget _buildReferralStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Referrals',
            _totalReferrals.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Successful',
            _successfulReferrals.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Rewards',
            '₹${_totalRewards.toStringAsFixed(0)}',
            Icons.card_giftcard,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCodeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Your Referral Code',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppConstants.primaryColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _referralCode,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _copyReferralCode,
                    icon: const Icon(Icons.copy),
                    color: AppConstants.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share this code with your friends. They get ₹25 off their first booking, and you earn ₹50 when they complete their first service!',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _copyReferralCode() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildShareOptions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share with Friends',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildShareOption(
              'WhatsApp',
              'Share via WhatsApp',
              Icons.chat,
              Colors.green,
              () => _shareViaWhatsApp(),
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              'SMS',
              'Share via SMS',
              Icons.sms,
              Colors.blue,
              () => _shareViaSMS(),
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              'Email',
              'Share via Email',
              Icons.email,
              Colors.orange,
              () => _shareViaEmail(),
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              'More Options',
              'Share via other apps',
              Icons.share,
              Colors.grey,
              () => _shareViaOther(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _shareViaWhatsApp() {
    final message =
        'Hey! I\'m using One Click 2 Service for all my home services. Use my referral code $_referralCode to get ₹25 off your first booking! Download the app now.';
    // TODO: Implement WhatsApp sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp sharing coming soon')),
    );
  }

  void _shareViaSMS() {
    final message =
        'Hey! I\'m using One Click 2 Service for all my home services. Use my referral code $_referralCode to get ₹25 off your first booking! Download the app now.';
    // TODO: Implement SMS sharing
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('SMS sharing coming soon')));
  }

  void _shareViaEmail() {
    final subject = 'Join One Click 2 Service - Get ₹25 Off!';
    final message =
        'Hey! I\'m using One Click 2 Service for all my home services. Use my referral code $_referralCode to get ₹25 off your first booking! Download the app now.';
    // TODO: Implement email sharing
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Email sharing coming soon')));
  }

  void _shareViaOther() {
    final message =
        'Hey! I\'m using One Click 2 Service for all my home services. Use my referral code $_referralCode to get ₹25 off your first booking! Download the app now.';
    // TODO: Implement general sharing
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sharing coming soon')));
  }

  Widget _buildReferralHistory() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Referral History',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_referralHistory.isEmpty)
              _buildEmptyHistory()
            else
              ..._referralHistory.map(
                (referral) => _buildReferralItem(referral),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No referrals yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start sharing to see your referral history here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralItem(Map<String, dynamic> referral) {
    final status = referral['status'] as String;
    final isCompleted = status == 'completed';
    final statusColor = isCompleted ? Colors.green : Colors.orange;
    final statusIcon = isCompleted ? Icons.check_circle : Icons.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppConstants.primaryColor,
            child: Text(
              (referral['name'] as String)[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral['name'] as String,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  referral['phone'] as String,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  _formatDate(referral['date'] as DateTime),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (isCompleted)
                Text(
                  '₹${referral['reward'].toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Rewards & Benefits',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRewardItem(
              '₹50 for each successful referral',
              'Earn ₹50 when your friend completes their first service',
              Icons.monetization_on,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildRewardItem(
              '₹25 off for your friends',
              'Your friends get ₹25 off their first booking',
              Icons.discount,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildRewardItem(
              'No limit on referrals',
              'Refer as many friends as you want',
              Icons.all_inclusive,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            CustomButton(text: 'Withdraw Rewards', onPressed: _withdrawRewards),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _withdrawRewards() {
    if (_totalRewards > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Withdraw Rewards'),
          content: Text(
            'You have ₹${_totalRewards.toStringAsFixed(0)} in rewards. How would you like to withdraw?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reward withdrawal coming soon'),
                  ),
                );
              },
              child: const Text('Withdraw'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No rewards available for withdrawal')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
