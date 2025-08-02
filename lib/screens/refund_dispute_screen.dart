import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';
import '../models/booking_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RefundDisputeScreen extends StatefulWidget {
  final PaymentRecord payment;
  final BookingModel booking;

  const RefundDisputeScreen({
    Key? key,
    required this.payment,
    required this.booking,
  }) : super(key: key);

  @override
  State<RefundDisputeScreen> createState() => _RefundDisputeScreenState();
}

class _RefundDisputeScreenState extends State<RefundDisputeScreen> {
  final PaymentService _paymentService = PaymentService();

  // Form controllers
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // State variables
  String _selectedType = 'refund';
  String _selectedReason = '';
  bool _isSubmitting = false;
  String? _error;
  String? _successMessage;

  // Available options
  final List<String> _typeOptions = ['refund', 'dispute'];
  final List<String> _refundReasons = [
    'Service not provided',
    'Poor service quality',
    'Provider did not arrive',
    'Service cancelled by provider',
    'Double payment',
    'Technical error',
    'Other',
  ];
  final List<String> _disputeReasons = [
    'Incorrect amount charged',
    'Service not as described',
    'Provider misconduct',
    'Safety concerns',
    'Billing error',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  List<String> get _currentReasons {
    return _selectedType == 'refund' ? _refundReasons : _disputeReasons;
  }

  Future<void> _submitRequest() async {
    if (!_validateForm()) return;

    try {
      setState(() {
        _isSubmitting = true;
        _error = null;
        _successMessage = null;
      });

      if (_selectedType == 'refund') {
        await _processRefundRequest();
      } else {
        await _processDisputeRequest();
      }

      setState(() {
        _isSubmitting = false;
        _successMessage = _selectedType == 'refund'
            ? 'Refund request submitted successfully. You will receive an update within 24-48 hours.'
            : 'Dispute filed successfully. Our team will review and contact you within 24 hours.';
      });

      // Clear form
      _clearForm();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = 'Failed to submit request: $e';
      });
    }
  }

  Future<void> _processRefundRequest() async {
    final refundData = {
      'payment_id': widget.payment.id,
      'booking_id': widget.booking.id,
      'amount': widget.payment.amount,
      'reason': _selectedReason,
      'description': _descriptionController.text,
      'contact_info': _contactController.text,
      'requested_at': DateTime.now().toIso8601String(),
    };

    // TODO: Submit to Supabase refund_requests table
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    // Update payment status to 'refund_pending'
    await _paymentService.updatePaymentStatus(
      widget.payment.id,
      'refund_pending',
      {'refund_request': refundData},
    );
  }

  Future<void> _processDisputeRequest() async {
    final disputeData = {
      'payment_id': widget.payment.id,
      'booking_id': widget.booking.id,
      'reason': _selectedReason,
      'description': _descriptionController.text,
      'contact_info': _contactController.text,
      'filed_at': DateTime.now().toIso8601String(),
    };

    // TODO: Submit to Supabase disputes table
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    // Update payment status to 'disputed'
    await _paymentService.updatePaymentStatus(widget.payment.id, 'disputed', {
      'dispute_request': disputeData,
    });
  }

  bool _validateForm() {
    if (_selectedReason.isEmpty) {
      setState(() {
        _error = 'Please select a reason';
      });
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please provide a detailed description';
      });
      return false;
    }

    if (_contactController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please provide contact information';
      });
      return false;
    }

    return true;
  }

  void _clearForm() {
    _selectedReason = '';
    _descriptionController.clear();
    _contactController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_selectedType == 'refund' ? 'Refund' : 'Dispute'} Request',
        ),
        actions: [
          IconButton(
            onPressed: () => _showHelpDialog(),
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Information Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Transaction ID',
                      widget.payment.transactionId ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Amount',
                      '₹${widget.payment.amount.toStringAsFixed(2)}',
                    ),
                    _buildInfoRow(
                      'Payment Method',
                      widget.payment.paymentMethod.toUpperCase(),
                    ),
                    _buildInfoRow(
                      'Date',
                      _formatDateTime(widget.payment.createdAt),
                    ),
                    _buildInfoRow(
                      'Status',
                      widget.payment.status.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Request Type Selection
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: _typeOptions
                          .map(
                            (type) => Expanded(
                              child: RadioListTile<String>(
                                title: Text(type.toUpperCase()),
                                value: type,
                                groupValue: _selectedType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                    _selectedReason = '';
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reason Selection
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedType == 'refund' ? 'Refund' : 'Dispute'} Reason',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedReason.isEmpty ? null : _selectedReason,
                      decoration: const InputDecoration(
                        labelText: 'Select Reason',
                        border: OutlineInputBorder(),
                      ),
                      items: _currentReasons
                          .map(
                            (reason) => DropdownMenuItem(
                              value: reason,
                              child: Text(reason),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Please provide detailed information',
                      hintText:
                          'Describe what happened and why you are requesting a ${_selectedType}...',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide a detailed description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _contactController,
                      labelText: 'Best contact method',
                      hintText: 'Phone number or email address',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide contact information';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error/Success Messages
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
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

            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),

            if (_error != null || _successMessage != null)
              const SizedBox(height: 16),

            // Submit Button
            CustomButton(
              onPressed: _isSubmitting ? null : _submitRequest,
              text: _isSubmitting
                  ? 'Submitting...'
                  : 'Submit ${_selectedType == 'refund' ? 'Refund' : 'Dispute'} Request',
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 12),

            // Cancel Button
            CustomOutlinedButton(
              onPressed: () => Navigator.pop(context),
              text: 'Cancel',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Refund Requests:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Refunds are processed within 5-7 business days\n'
                '• You will receive an email confirmation\n'
                '• Refunds are credited to your original payment method\n'
                '• Processing time may vary based on your bank',
              ),
              const SizedBox(height: 16),
              const Text(
                'Dispute Resolution:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Disputes are reviewed within 24-48 hours\n'
                '• Our team will contact you for additional information\n'
                '• Resolution time depends on complexity\n'
                '• You can track status in your account',
              ),
              const SizedBox(height: 16),
              const Text(
                'Contact Support:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Email: support@oneclick2service.com\n'
                'Phone: +91-XXXXXXXXXX\n'
                'Hours: 9 AM - 6 PM (IST)',
              ),
            ],
          ),
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
}
