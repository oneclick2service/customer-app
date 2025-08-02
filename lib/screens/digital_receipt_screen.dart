import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../models/booking_model.dart';

class DigitalReceiptScreen extends StatefulWidget {
  final BookingModel booking;
  final String transactionId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;

  const DigitalReceiptScreen({
    Key? key,
    required this.booking,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
  }) : super(key: key);

  @override
  State<DigitalReceiptScreen> createState() => _DigitalReceiptScreenState();
}

class _DigitalReceiptScreenState extends State<DigitalReceiptScreen> {
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Receipt'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _shareReceipt,
            icon: const Icon(Icons.share),
            tooltip: 'Share Receipt',
          ),
          IconButton(
            onPressed: _downloadReceipt,
            icon: const Icon(Icons.download),
            tooltip: 'Download Receipt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Receipt Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Company Logo and Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.home_repair_service,
                            color: Colors.blue.shade700,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OneClick2Service',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Your Trusted Service Partner',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Receipt Title
                    const Text(
                      'PAYMENT RECEIPT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transaction ID: ${widget.transactionId}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Service Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Service Type', widget.booking.serviceType),
                    _buildDetailRow(
                      'Service Category',
                      widget.booking.serviceCategory,
                    ),
                    _buildDetailRow('Description', widget.booking.description),
                    _buildDetailRow(
                      'Provider ID',
                      widget.booking.serviceProviderId ?? 'Not Assigned',
                    ),
                    _buildDetailRow(
                      'Scheduled Date',
                      _formatDate(widget.booking.scheduledDate),
                    ),
                    _buildDetailRow(
                      'Status',
                      widget.booking.status.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Payment Method', widget.paymentMethod),
                    _buildDetailRow(
                      'Payment Date',
                      _formatDateTime(widget.paymentDate),
                    ),
                    _buildDetailRow('Transaction ID', widget.transactionId),
                    _buildDetailRow(
                      'Amount Paid',
                      '₹${widget.amount.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pricing Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pricing Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPricingRow(
                      'Base Service Charge',
                      widget.amount * 0.85,
                    ),
                    _buildPricingRow('Platform Fee (5%)', widget.amount * 0.05),
                    _buildPricingRow('GST (18%)', widget.amount * 0.18),
                    const Divider(),
                    _buildPricingRow(
                      'Total Amount',
                      widget.amount,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Company Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Company', 'OneClick2Service Pvt. Ltd.'),
                    _buildDetailRow(
                      'Address',
                      'Vijayawada, Andhra Pradesh, India',
                    ),
                    _buildDetailRow('GST Number', 'GST1234567890123'),
                    _buildDetailRow('Contact', '+91-9876543210'),
                    _buildDetailRow('Email', 'support@oneclick2service.com'),
                    _buildDetailRow('Website', 'www.oneclick2service.com'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Terms and Conditions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• This receipt is valid for tax purposes\n'
                      '• Service guarantee applies as per terms\n'
                      '• Cancellation policy is applicable\n'
                      '• For support, contact our customer service\n'
                      '• This is a computer-generated receipt',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: _isDownloading ? null : _downloadReceipt,
                    text: _isDownloading ? 'Downloading...' : 'Download PDF',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: _isSharing ? null : _shareReceipt,
                    text: _isSharing ? 'Sharing...' : 'Share Receipt',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Copy Transaction ID
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _copyTransactionId,
                text: 'Copy Transaction ID',
              ),
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
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _downloadReceipt() async {
    setState(() {
      _isDownloading = true;
    });

    // Simulate download process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isDownloading = false;
    });

    _showSnackBar('Receipt downloaded successfully');
  }

  void _shareReceipt() async {
    setState(() {
      _isSharing = true;
    });

    // Simulate sharing process
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSharing = false;
    });

    _showSnackBar('Receipt shared successfully');
  }

  void _copyTransactionId() {
    Clipboard.setData(ClipboardData(text: widget.transactionId));
    _showSnackBar('Transaction ID copied to clipboard');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
