import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/booking_model.dart';
import '../services/payment_service.dart';

class UpiPaymentScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const UpiPaymentScreen({
    Key? key,
    required this.booking,
    required this.amount,
  }) : super(key: key);

  @override
  State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  bool _isQrGenerated = false;
  String? _qrData;
  String? _transactionId;
  String _paymentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _validateUpiId(String upiId) {
    return _paymentService.isValidUPI(upiId);
  }

  void _generateQrCode() {
    if (_upiIdController.text.isEmpty) {
      _showSnackBar('Please enter a UPI ID');
      return;
    }

    if (!_validateUpiId(_upiIdController.text)) {
      _showSnackBar('Please enter a valid UPI ID (e.g., name@bank)');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Generate UPI payment URL using payment service
    final upiUrl = _paymentService.generateUpiUrl(
      payeeVpa: _upiIdController.text,
      amount: double.parse(_amountController.text),
      transactionNote: 'Booking ${widget.booking.id}',
      merchantName: 'OneClick2Service',
    );

    setState(() {
      _qrData = upiUrl;
      _isQrGenerated = true;
      _isLoading = false;
    });
  }

  void _copyUpiId() {
    if (_upiIdController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _upiIdController.text));
      _showSnackBar('UPI ID copied to clipboard');
    }
  }

  void _initiatePayment() async {
    if (!_isQrGenerated) {
      _showSnackBar('Please generate QR code first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Generate transaction ID
    final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _transactionId = transactionId;
      _paymentStatus = 'processing';
      _isLoading = false;
    });

    // Simulate payment completion
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _paymentStatus = 'completed';
    });

    _showPaymentSuccessDialog();
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: $_transactionId'),
            const SizedBox(height: 8),
            Text('Amount: ₹${_amountController.text}'),
            const SizedBox(height: 8),
            Text('UPI ID: ${_upiIdController.text}'),
            const SizedBox(height: 8),
            const Text('Your payment has been processed successfully.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('OK'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Details Card
            Card(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service:'),
                        Text(widget.booking.serviceType),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Provider:'),
                        Text(
                          widget.booking.serviceProviderId ?? 'Not Assigned',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          '₹${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // UPI ID Input
            const Text(
              'Enter UPI ID',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _upiIdController,
                    hintText: 'Enter UPI ID (e.g., name@bank)',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _copyUpiId,
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy UPI ID',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Generate QR Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _isLoading ? null : _generateQrCode,
                text: _isLoading ? 'Generating...' : 'Generate QR Code',
              ),
            ),
            const SizedBox(height: 24),

            // QR Code Display
            if (_isQrGenerated) ...[
              const Text(
                'Scan QR Code to Pay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'QR Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'UPI ID: ${_upiIdController.text}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Amount: ₹${_amountController.text}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Status
              if (_transactionId != null) ...[
                Card(
                  color: _paymentStatus == 'completed'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _paymentStatus == 'completed'
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: _paymentStatus == 'completed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _paymentStatus == 'completed'
                                  ? 'Payment Completed'
                                  : 'Payment Processing',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _paymentStatus == 'completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Transaction ID: $_transactionId'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pay Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _isLoading || _paymentStatus == 'completed'
                      ? null
                      : _initiatePayment,
                  text: _isLoading
                      ? 'Processing...'
                      : _paymentStatus == 'completed'
                      ? 'Payment Completed'
                      : 'Pay Now',
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Payment Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Pay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Open your UPI app (Google Pay, PhonePe, Paytm, etc.)\n'
                      '2. Scan the QR code above\n'
                      '3. Verify the payment details\n'
                      '4. Enter your UPI PIN\n'
                      '5. Complete the payment',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
