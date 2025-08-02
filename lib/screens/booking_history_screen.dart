import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../services/booking_status_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'booking_status_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<BookingModel> _allBookings = [];
  List<BookingModel> _filteredBookings = [];
  bool _isLoading = true;
  String? _error;

  // Filter states
  String _selectedStatus = 'All';
  String _selectedService = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  // Sort states
  String _sortBy = 'date';
  bool _sortDescending = true;

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Assigned',
    'En Route',
    'Arrived',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  final List<String> _serviceOptions = [
    'All',
    'Electrical',
    'Plumbing',
    'Cleaning',
    'Glass Work',
    'Mechanical',
    'Custom',
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'date', 'label': 'Date'},
    {'value': 'status', 'label': 'Status'},
    {'value': 'amount', 'label': 'Amount'},
    {'value': 'provider', 'label': 'Provider'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBookingHistory();
  }

  Future<void> _loadBookingHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      await bookingProvider.loadUserBookings();

      setState(() {
        _allBookings = bookingProvider.bookings;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load booking history: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredBookings = _allBookings.where((booking) {
      // Status filter
      if (_selectedStatus != 'All' && booking.status != _selectedStatus) {
        return false;
      }

      // Service filter
      if (_selectedService != 'All' &&
          booking.serviceCategory != _selectedService) {
        return false;
      }

      // Date range filter
      if (_startDate != null && booking.createdAt.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && booking.createdAt.isAfter(_endDate!)) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch =
            booking.description.toLowerCase().contains(query) ||
            booking.id.toLowerCase().contains(query);
        if (!matchesSearch) {
          return false;
        }
      }

      return true;
    }).toList();

    _sortBookings();
  }

  void _sortBookings() {
    _filteredBookings.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'provider':
          comparison =
              a.serviceProviderId?.compareTo(b.serviceProviderId ?? '') ?? 0;
          break;
      }
      return _sortDescending ? -comparison : comparison;
    });
  }

  void _showFilterDialog() {
    showDialog(context: context, builder: (context) => _buildFilterDialog());
  }

  Widget _buildFilterDialog() {
    return AlertDialog(
      title: const Text('Filter Bookings'),
      content: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status filter
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Service filter
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                ),
                items: _serviceOptions.map((service) {
                  return DropdownMenuItem(value: service, child: Text(service));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedService = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _startDate == null
                            ? 'Start Date'
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _endDate == null
                            ? 'End Date'
                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Clear filters button
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = 'All';
                    _selectedService = 'All';
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _applyFilters();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Bookings'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._sortOptions.map(
                (option) => RadioListTile<String>(
                  title: Text(option['label']!),
                  value: option['value']!,
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Order:'),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Newest First'),
                    selected: _sortDescending,
                    onSelected: (selected) {
                      setState(() {
                        _sortDescending = selected;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Oldest First'),
                    selected: !_sortDescending,
                    onSelected: (selected) {
                      setState(() {
                        _sortDescending = !selected;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sortBookings();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _rebookService(BookingModel booking) {
    // Navigate to provider selection with the same service
    Navigator.pushNamed(
      context,
      '/provider-selection',
      arguments: {
        'serviceCategory': booking.serviceCategory,
        'serviceDescription': booking.description,
        'estimatedAmount': booking.amount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(onPressed: _showSortDialog, icon: const Icon(Icons.sort)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildBookingList()),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load booking history',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBookingHistory,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomTextField(
        hintText: 'Search bookings...',
        prefixIcon: const Icon(Icons.search),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildBookingList() {
    if (_filteredBookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadBookingHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = _filteredBookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Your booking history will appear here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Book a Service',
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusInfo = BookingStatusService.getStatusInfo(booking.status);
    final isCompleted = booking.status == 'Completed';
    final canRebook = isCompleted || booking.status == 'Cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusInfo['color'].withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
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
                        booking.serviceCategory,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        statusInfo['title'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: statusInfo['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${booking.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service description
                Text(
                  booking.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Provider info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppConstants.primaryColor,
                      child: Text(
                        booking.serviceProviderId != null
                            ? booking.serviceProviderId![0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceProviderId != null
                                ? 'Provider ID: ${booking.serviceProviderId}'
                                : 'Provider not assigned',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (booking.rating != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.rating!.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Booking details
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(booking.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      'ID: ${booking.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'View Details',
                    variant: ButtonVariant.outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingStatusScreen(bookingId: booking.id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                if (canRebook)
                  Expanded(
                    child: CustomButton(
                      text: 'Rebook',
                      onPressed: () => _rebookService(booking),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
