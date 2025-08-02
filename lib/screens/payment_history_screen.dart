import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';
import '../models/booking_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentService _paymentService = PaymentService();
  List<PaymentRecord> _payments = [];
  List<PaymentRecord> _filteredPayments = [];
  bool _isLoading = true;
  String? _error;

  // Filter states
  String _selectedStatus = 'All';
  String _selectedMethod = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  // Sort states
  String _sortBy = 'date';
  bool _sortDescending = true;

  final List<String> _statusOptions = [
    'All',
    'Success',
    'Failed',
    'Pending',
    'Refunded',
  ];
  final List<String> _methodOptions = ['All', 'UPI', 'Card', 'Wallet', 'Cash'];
  final List<Map<String, String>> _sortOptions = [
    {'value': 'date', 'label': 'Date'},
    {'value': 'amount', 'label': 'Amount'},
    {'value': 'status', 'label': 'Status'},
    {'value': 'method', 'label': 'Payment Method'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final payments = await _paymentService.getPaymentHistory();

      setState(() {
        _payments = payments;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load payment history: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredPayments = _payments.where((payment) {
      // Status filter
      if (_selectedStatus != 'All' &&
          payment.status != _selectedStatus.toLowerCase()) {
        return false;
      }

      // Method filter
      if (_selectedMethod != 'All' &&
          payment.paymentMethod != _selectedMethod.toLowerCase()) {
        return false;
      }

      // Date range filter
      if (_startDate != null && payment.createdAt.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && payment.createdAt.isAfter(_endDate!)) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTransactionId =
            payment.transactionId?.toLowerCase().contains(query) ?? false;
        final matchesAmount = payment.amount.toString().contains(query);
        final matchesBookingId = payment.bookingId.toLowerCase().contains(
          query,
        );

        if (!matchesTransactionId && !matchesAmount && !matchesBookingId) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    _applySorting();
  }

  void _applySorting() {
    _filteredPayments.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'method':
          comparison = a.paymentMethod.compareTo(b.paymentMethod);
          break;
      }

      return _sortDescending ? -comparison : comparison;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Payments'),
        content: SizedBox(
          width: double.maxFinite,
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
                items: _statusOptions
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Method filter
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: _methodOptions
                    .map(
                      (method) =>
                          DropdownMenuItem(value: method, child: Text(method)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value!;
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = 'All';
                _selectedMethod = 'All';
                _startDate = null;
                _endDate = null;
                _searchQuery = '';
              });
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Payments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sort by
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: const InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(),
              ),
              items: _sortOptions
                  .map(
                    (option) => DropdownMenuItem(
                      value: option['value'],
                      child: Text(option['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Sort order
            Row(
              children: [
                const Text('Sort Order: '),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Newest First'),
                  selected: _sortDescending,
                  onSelected: (bool selected) {
                    setState(() {
                      _sortDescending = true;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Oldest First'),
                  selected: !_sortDescending,
                  onSelected: (bool selected) {
                    setState(() {
                      _sortDescending = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _applySorting();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(PaymentRecord payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Transaction ID', payment.transactionId ?? 'N/A'),
              _buildDetailRow('Booking ID', payment.bookingId),
              _buildDetailRow(
                'Amount',
                '₹${payment.amount.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Currency', payment.currency),
              _buildDetailRow(
                'Payment Method',
                payment.paymentMethod.toUpperCase(),
              ),
              _buildDetailRow('Status', payment.status.toUpperCase()),
              _buildDetailRow('Created', _formatDateTime(payment.createdAt)),
              _buildDetailRow('Updated', _formatDateTime(payment.updatedAt)),
              if (payment.metadata.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Additional Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...payment.metadata.entries.map(
                  (entry) => _buildDetailRow(entry.key, entry.value.toString()),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (payment.status == 'success')
            ElevatedButton.icon(
              onPressed: () => _downloadReceipt(payment),
              icon: const Icon(Icons.download),
              label: const Text('Download Receipt'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _downloadReceipt(PaymentRecord payment) async {
    try {
      final receipt = await _paymentService.generateReceipt(payment.id);
      // TODO: Implement actual receipt download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt downloaded: ${receipt['filename']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download receipt: $e')));
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return Icons.account_balance_wallet;
      case 'card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: TextEditingController(text: _searchQuery),
              labelText: 'Search payments...',
              hintText: 'Transaction ID, amount, or booking ID',
              prefixIcon: Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ),

          // Summary stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _filteredPayments.length.toString(),
                    Icons.list,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Success',
                    _filteredPayments
                        .where((p) => p.status == 'success')
                        .length
                        .toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Failed',
                    _filteredPayments
                        .where((p) => p.status == 'failed')
                        .length
                        .toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Payment list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          onPressed: _loadPaymentHistory,
                          text: 'Retry',
                        ),
                      ],
                    ),
                  )
                : _filteredPayments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _payments.isEmpty
                              ? 'No payments found'
                              : 'No payments match your filters',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (_payments.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          CustomButton(
                            onPressed: () {
                              setState(() {
                                _selectedStatus = 'All';
                                _selectedMethod = 'All';
                                _startDate = null;
                                _endDate = null;
                                _searchQuery = '';
                              });
                              _applyFilters();
                            },
                            text: 'Clear Filters',
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPaymentHistory,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = _filteredPayments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(payment.status),
                              child: Icon(
                                _getMethodIcon(payment.paymentMethod),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              '₹${payment.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(payment.paymentMethod.toUpperCase()),
                                Text(
                                  _formatDateTime(payment.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                if (payment.transactionId != null)
                                  Text(
                                    'ID: ${payment.transactionId}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(payment.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                payment.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () => _showPaymentDetails(payment),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
