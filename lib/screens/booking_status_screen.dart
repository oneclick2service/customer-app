import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../services/booking_status_service.dart';
import '../widgets/custom_button.dart';

class BookingStatusScreen extends StatefulWidget {
  final String bookingId;

  const BookingStatusScreen({Key? key, required this.bookingId})
    : super(key: key);

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen> {
  final BookingStatusService _statusService = BookingStatusService();
  BookingModel? _booking;
  List<Map<String, dynamic>> _statusHistory = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
    _setupStatusListener();
  }

  @override
  void dispose() {
    _statusService.removeStatusUpdateListener(_onStatusUpdate);
    super.dispose();
  }

  void _setupStatusListener() {
    _statusService.addStatusUpdateListener(_onStatusUpdate);
  }

  void _onStatusUpdate(BookingModel updatedBooking) {
    if (updatedBooking.id == widget.bookingId) {
      setState(() {
        _booking = updatedBooking;
      });
      _loadStatusHistory();
    }
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      final booking = bookingProvider.bookings.firstWhere(
        (booking) => booking.id == widget.bookingId,
        orElse: () => throw Exception('Booking not found'),
      );

      setState(() {
        _booking = booking;
        _isLoading = false;
      });

      await _loadStatusHistory();
    } catch (e) {
      setState(() {
        _error = 'Failed to load booking details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatusHistory() async {
    try {
      final history = await _statusService.getBookingStatusHistory(
        widget.bookingId,
      );
      setState(() {
        _statusHistory = history;
      });
    } catch (e) {
      debugPrint('Error loading status history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Status'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
          ? _buildErrorWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingHeader(),
                  const SizedBox(height: 24),
                  _buildStatusTimeline(),
                  const SizedBox(height: 24),
                  _buildStatusHistory(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Failed to load booking',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Retry',
            onPressed: _loadBookingDetails,
            backgroundColor: AppConstants.primaryColor,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHeader() {
    final booking = _booking!;
    final statusInfo = BookingStatusService.getStatusInfo(booking.status);

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusInfo['icon'],
                  color: statusInfo['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo['title'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusInfo['color'],
                      ),
                    ),
                    Text(
                      statusInfo['description'],
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBookingInfoRow('Service', booking.serviceType),
          _buildBookingInfoRow('Category', booking.serviceCategory),
          _buildBookingInfoRow(
            'Amount',
            '₹${booking.amount.toStringAsFixed(2)}',
          ),
          _buildBookingInfoRow(
            'Scheduled',
            _formatDateTime(booking.scheduledDate),
          ),
          if (booking.customerAddress != null)
            _buildBookingInfoRow('Address', booking.customerAddress!),
        ],
      ),
    );
  }

  Widget _buildBookingInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      BookingStatusService.STATUS_PENDING,
      BookingStatusService.STATUS_CONFIRMED,
      BookingStatusService.STATUS_ASSIGNED,
      BookingStatusService.STATUS_EN_ROUTE,
      BookingStatusService.STATUS_ARRIVED,
      BookingStatusService.STATUS_IN_PROGRESS,
      BookingStatusService.STATUS_COMPLETED,
    ];

    final currentStatusIndex = statuses.indexOf(_booking!.status);
    final isCancelled =
        _booking!.status == BookingStatusService.STATUS_CANCELLED;

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
          Text(
            'Status Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (isCancelled)
            _buildCancelledStatus()
          else
            ...statuses.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final statusInfo = BookingStatusService.getStatusInfo(status);
              final isCompleted = index <= currentStatusIndex;
              final isCurrent = index == currentStatusIndex;

              return _buildTimelineItem(
                statusInfo['title'],
                statusInfo['description'],
                statusInfo['icon'],
                statusInfo['color'],
                isCompleted,
                isCurrent,
                index == statuses.length - 1,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildCancelledStatus() {
    final statusInfo = BookingStatusService.getStatusInfo(
      BookingStatusService.STATUS_CANCELLED,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(statusInfo['icon'], color: statusInfo['color'], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['title'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusInfo['color'],
                  ),
                ),
                Text(
                  statusInfo['description'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                if (_booking!.cancellationReason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reason: ${_booking!.cancellationReason}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.red[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isCompleted,
    bool isCurrent,
    bool isLast,
  ) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? color : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCurrent
                        ? color
                        : (isCompleted ? Colors.grey[800] : Colors.grey[600]),
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Current',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHistory() {
    if (_statusHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No status history yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Status updates will appear here',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
          Text(
            'Status History',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._statusHistory
              .map((history) => _buildHistoryItem(history))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> history) {
    final status = history['status'] as String;
    final timestamp = DateTime.parse(history['created_at'] as String);
    final statusInfo = BookingStatusService.getStatusInfo(status);

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
          Icon(statusInfo['icon'], color: statusInfo['color'], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['title'],
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatDateTime(timestamp),
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

  Widget _buildActionButtons() {
    final currentStatus = _booking!.status;
    final nextStatuses = BookingStatusService.getNextPossibleStatuses(
      currentStatus,
    );

    if (nextStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: nextStatuses.map((status) {
            final statusInfo = BookingStatusService.getStatusInfo(status);
            return CustomButton(
              text: statusInfo['title'],
              onPressed: () => _updateStatus(status),
              backgroundColor: statusInfo['color'],
              textColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text(
          'Are you sure you want to update the status to "${BookingStatusService.getStatusInfo(newStatus)['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _statusService.updateBookingStatus(
          widget.bookingId,
          newStatus,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Status updated to ${BookingStatusService.getStatusInfo(newStatus)['title']}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update status'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating status: $e'),
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
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
