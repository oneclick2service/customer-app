import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../models/service_provider_model.dart';
import '../models/booking_model.dart';
import '../widgets/custom_button.dart';

class DirectCallScreen extends StatefulWidget {
  final ServiceProvider? provider;
  final Booking? booking;

  const DirectCallScreen({Key? key, this.provider, this.booking})
    : super(key: key);

  @override
  State<DirectCallScreen> createState() => _DirectCallScreenState();
}

class _DirectCallScreenState extends State<DirectCallScreen> {
  List<CallHistory> _callHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
  }

  Future<void> _loadCallHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load call history from Supabase
      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _callHistory = [
          CallHistory(
            id: '1',
            providerId: widget.provider?.id ?? 'provider_1',
            providerName: widget.provider?.name ?? 'John Electrician',
            phoneNumber: widget.provider?.phone ?? '+91 9876543210',
            callType: CallType.outgoing,
            duration: const Duration(minutes: 5, seconds: 32),
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            bookingId: widget.booking?.id,
          ),
          CallHistory(
            id: '2',
            providerId: widget.provider?.id ?? 'provider_1',
            providerName: widget.provider?.name ?? 'John Electrician',
            phoneNumber: widget.provider?.phone ?? '+91 9876543210',
            callType: CallType.incoming,
            duration: const Duration(minutes: 2, seconds: 15),
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            bookingId: widget.booking?.id,
          ),
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load call history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);

        // Add to call history
        _addToCallHistory(phoneNumber, CallType.outgoing);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Calling service provider...'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw 'Could not launch phone app';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToCallHistory(String phoneNumber, CallType callType) {
    final callHistory = CallHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      providerId: widget.provider?.id ?? 'unknown',
      providerName: widget.provider?.name ?? 'Unknown Provider',
      phoneNumber: phoneNumber,
      callType: callType,
      duration: const Duration(seconds: 0),
      timestamp: DateTime.now(),
      bookingId: widget.booking?.id,
    );

    setState(() {
      _callHistory.insert(0, callHistory);
    });

    // TODO: Save to Supabase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Call'),
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
                  // Provider info card
                  if (widget.provider != null) _buildProviderCard(),

                  const SizedBox(height: 24),

                  // Call actions
                  _buildCallActions(),

                  const SizedBox(height: 24),

                  // Call history
                  _buildCallHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildProviderCard() {
    final provider = widget.provider!;

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                child: Text(
                  provider.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.specializations.join(', '),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.rating} (${provider.reviewCount} reviews)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                provider.phone,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Call Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Call Now',
                onPressed: () => _makeCall(widget.provider?.phone ?? ''),
                backgroundColor: Colors.green,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Add to Contacts',
                onPressed: _addToContacts,
                backgroundColor: AppConstants.primaryColor,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Send Message',
                onPressed: _sendMessage,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Share Contact',
                onPressed: _shareContact,
                backgroundColor: Colors.orange,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Call History',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _callHistory.isEmpty ? null : _clearCallHistory,
              child: Text(
                'Clear All',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_callHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No call history yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your calls with service providers will appear here',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _callHistory.length,
            itemBuilder: (context, index) {
              final call = _callHistory[index];
              return _buildCallHistoryItem(call);
            },
          ),
      ],
    );
  }

  Widget _buildCallHistoryItem(CallHistory call) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: call.callType == CallType.outgoing
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              call.callType == CallType.outgoing
                  ? Icons.call_made
                  : Icons.call_received,
              color: call.callType == CallType.outgoing
                  ? Colors.green
                  : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.providerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  call.phoneNumber,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(call.duration),
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
              Text(
                _formatTimestamp(call.timestamp),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _makeCall(call.phoneNumber),
                    icon: Icon(Icons.call, color: AppConstants.primaryColor),
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: () => _sendMessageToNumber(call.phoneNumber),
                    icon: Icon(Icons.message, color: AppConstants.primaryColor),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _addToContacts() async {
    // TODO: Implement add to contacts functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add to contacts functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _sendMessage() async {
    // TODO: Navigate to chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chat...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _shareContact() async {
    // TODO: Implement share contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share contact functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _sendMessageToNumber(String phoneNumber) async {
    // TODO: Navigate to chat screen with specific provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chat...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _clearCallHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Call History'),
        content: const Text(
          'Are you sure you want to clear all call history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Clear', style: TextStyle(color: Colors.red[600])),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _callHistory.clear();
      });

      // TODO: Clear from Supabase

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call history cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

enum CallType { incoming, outgoing, missed }

class CallHistory {
  final String id;
  final String providerId;
  final String providerName;
  final String phoneNumber;
  final CallType callType;
  final Duration duration;
  final DateTime timestamp;
  final String? bookingId;

  CallHistory({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.phoneNumber,
    required this.callType,
    required this.duration,
    required this.timestamp,
    this.bookingId,
  });
}
