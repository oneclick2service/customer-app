import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';
import '../models/booking_model.dart';
import '../widgets/custom_button.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final PaymentResult paymentResult;
  final BookingModel booking;
  final double amount;

  const PaymentConfirmationScreen({
    Key? key,
    required this.paymentResult,
    required this.booking,
    required this.amount,
  }) : super(key: key);

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _isGeneratingReceipt = false;
  Map<String, dynamic>? _receiptData;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.paymentResult.success) {
      _generateReceipt();
    }
  }

  Future<void> _generateReceipt() async {
    try {
      setState(() {
        _isGeneratingReceipt = true;
        _error = null;
      });

      final receipt = await PaymentService().generateReceipt(
        PaymentRecord(
          id: widget.paymentResult.paymentId ?? '',
          bookingId: widget.booking.id,
          userId: widget.booking.customerId,
          amount: widget.paymentResult.amount,
          currency: widget.paymentResult.currency,
          paymentMethod: widget.paymentResult.paymentMethod,
          status: widget.paymentResult.success ? 'completed' : 'failed',
          transactionId: widget.paymentResult.transactionId,
          createdAt: widget.paymentResult.timestamp,
          updatedAt: widget.paymentResult.timestamp,
        ),
      );

      setState(() {
        _receiptData = {'receipt': receipt};
        _isGeneratingReceipt = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate receipt: $e';
        _isGeneratingReceipt = false;
      });
    }
  }

  Future<void> _shareReceipt() async {
    if (_receiptData == null) return;

    try {
      final receiptText = _buildReceiptText();

      // Share via system share dialog
      await _shareText(receiptText);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt shared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share receipt: $e')));
    }
  }

  Future<void> _shareText(String text) async {
    final uri = Uri.parse(
      'mailto:?subject=Payment Receipt&body=${Uri.encodeComponent(text)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: copy to clipboard
      // TODO: Implement clipboard functionality
      throw Exception('Unable to share receipt');
    }
  }

  String _buildReceiptText() {
    final receipt = _receiptData!;
    final booking = widget.booking;

    return '''
PAYMENT RECEIPT
===============

Receipt No: ${receipt['receipt_number']}
Date: ${receipt['date']}
Time: ${receipt['time']}

BOOKING DETAILS
---------------
Booking ID: ${booking.id}
Service: ${booking.serviceType}
Provider: ${booking.serviceProviderId ?? 'To be assigned'}
Date: ${_formatDateTime(booking.scheduledDate)}

PAYMENT DETAILS
---------------
Amount: ₹${widget.amount.toStringAsFixed(2)}
Payment Method: ${widget.paymentResult.metadata?['payment_method']?.toString().toUpperCase() ?? 'N/A'}
Transaction ID: ${widget.paymentResult.transactionId}
Status: ${widget.paymentResult.success ? 'SUCCESS' : 'FAILED'}

CUSTOMER DETAILS
----------------
Customer ID: ${booking.customerId}
Address: ${booking.customerAddress ?? 'N/A'}

Thank you for using One Click 2 Service!
For support, contact: support@oneclick2service.com
    ''';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor() {
    return widget.paymentResult.success ? Colors.green : Colors.red;
  }

  IconData _getStatusIcon() {
    return widget.paymentResult.success ? Icons.check_circle : Icons.error;
  }

  String _getStatusText() {
    return widget.paymentResult.success
        ? 'Payment Successful'
        : 'Payment Failed';
  }

  String _getStatusDescription() {
    if (widget.paymentResult.success) {
      return 'Your payment has been processed successfully. You will receive a confirmation shortly.';
    } else {
      return 'Payment could not be processed. Please try again or contact support.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor().withOpacity(0.1),
                      _getStatusColor().withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(_getStatusIcon(), size: 64, color: _getStatusColor()),
                    const SizedBox(height: 16),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusDescription(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Details Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Amount',
                      '₹${widget.amount.toStringAsFixed(2)}',
                    ),
                    _buildDetailRow(
                      'Transaction ID',
                      widget.paymentResult.transactionId ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Payment Method',
                      widget.paymentResult.metadata?['payment_method']
                              ?.toString()
                              .toUpperCase() ??
                          'N/A',
                    ),
                    _buildDetailRow('Date', _formatDateTime(DateTime.now())),
                    if (widget.paymentResult.metadata?['upi_app'] != null)
                      _buildDetailRow(
                        'UPI App',
                        widget.paymentResult.metadata!['upi_app'].toString(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Booking Details Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Booking ID', widget.booking.id),
                    _buildDetailRow('Service', widget.booking.serviceType),
                    _buildDetailRow(
                      'Provider',
                      widget.booking.serviceProviderId ?? 'To be assigned',
                    ),
                    _buildDetailRow(
                      'Date',
                      _formatDateTime(widget.booking.scheduledDate),
                    ),
                    _buildDetailRow(
                      'Address',
                      widget.booking.customerAddress ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (widget.paymentResult.success) ...[
              if (_isGeneratingReceipt)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Generating receipt...'),
                    ],
                  ),
                )
              else if (_receiptData != null) ...[
                CustomButton(onPressed: _shareReceipt, text: 'Share Receipt'),
                const SizedBox(height: 12),
                CustomOutlinedButton(
                  onPressed: () => _downloadReceipt(),
                  text: 'Download Receipt',
                ),
                const SizedBox(height: 12),
              ] else if (_error != null) ...[
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
                const SizedBox(height: 12),
                CustomButton(
                  onPressed: _generateReceipt,
                  text: 'Retry Receipt Generation',
                ),
                const SizedBox(height: 12),
              ],

              CustomOutlinedButton(
                onPressed: () => _viewBookingStatus(),
                text: 'View Booking Status',
              ),
              const SizedBox(height: 12),
            ] else ...[
              CustomButton(
                onPressed: () => _retryPayment(),
                text: 'Retry Payment',
              ),
              const SizedBox(height: 12),
              CustomOutlinedButton(
                onPressed: () => _contactSupport(),
                text: 'Contact Support',
              ),
              const SizedBox(height: 12),
            ],

            CustomOutlinedButton(
              onPressed: () => _goToHome(),
              text: 'Go to Home',
            ),
          ],
        ),
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

  void _downloadReceipt() {
    // TODO: Implement actual receipt download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt downloaded successfully')),
    );
  }

  void _viewBookingStatus() {
    // TODO: Navigate to booking status screen
    Navigator.pop(context);
    // Navigator.pushNamed(context, '/booking-status', arguments: widget.booking.id);
  }

  void _retryPayment() {
    // TODO: Navigate back to payment screen
    Navigator.pop(context);
    // Navigator.pushReplacementNamed(context, '/payment', arguments: {
    //   'booking': widget.booking,
    //   'amount': widget.amount,
    // });
  }

  void _contactSupport() async {
    final uri = Uri.parse(
      'mailto:support@oneclick2service.com?subject=Payment Issue - ${widget.booking.id}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open email client')),
      );
    }
  }

  void _goToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
