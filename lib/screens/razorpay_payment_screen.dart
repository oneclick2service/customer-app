import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/booking_model.dart';
import '../services/payment_service.dart';

class RazorpayPaymentScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const RazorpayPaymentScreen({
    Key? key,
    required this.booking,
    required this.amount,
  }) : super(key: key);

  @override
  State<RazorpayPaymentScreen> createState() => _RazorpayPaymentScreenState();
}

class _RazorpayPaymentScreenState extends State<RazorpayPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  String? _transactionId;
  String _paymentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _paymentService.initializeRazorpay();
    _prefillUserData();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _prefillUserData() {
    // Prefill with sample data - in real app, get from user profile
    _emailController.text = 'user@example.com';
    _phoneController.text = '+91 9876543210';
    _nameController.text = 'John Doe';
  }

  void _initiateRazorpayPayment() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _paymentService.processRazorpayPayment(
        booking: widget.booking,
        amount: widget.amount,
        currency: 'INR',
        userEmail: _emailController.text,
        userPhone: _phoneController.text,
        userName: _nameController.text,
      );

      if (result['success']) {
        setState(() {
          _transactionId = _paymentService.generateTransactionId();
          _paymentStatus = 'processing';
        });

        // Simulate payment completion
        await Future.delayed(const Duration(seconds: 3));

        setState(() {
          _paymentStatus = 'completed';
        });

        _showPaymentSuccessDialog();
      } else {
        _showSnackBar(result['message']);
      }
    } catch (e) {
      _showSnackBar('Payment failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateForm() {
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email');
      return false;
    }

    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter your phone number');
      return false;
    }

    if (_nameController.text.isEmpty) {
      _showSnackBar('Please enter your name');
      return false;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showSnackBar('Please enter a valid email address');
      return false;
    }

    return true;
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
            Text('Amount: ${_paymentService.formatAmount(widget.amount)}'),
            const SizedBox(height: 8),
            Text('Method: Razorpay'),
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
        title: const Text('Razorpay Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Razorpay Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                          _paymentService.formatAmount(widget.amount),
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

            // User Information Form
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _emailController,
              hintText: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _phoneController,
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(Icons.phone),
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
                    : _initiateRazorpayPayment,
                text: _isLoading
                    ? 'Processing...'
                    : _paymentStatus == 'completed'
                    ? 'Payment Completed'
                    : 'Pay with Razorpay',
              ),
            ),
            const SizedBox(height: 24),

            // Razorpay Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Text(
                          'Razorpay Features',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Secure payment processing\n'
                      '• Multiple payment options (UPI, Cards, Wallets)\n'
                      '• Real-time transaction status\n'
                      '• Built-in fraud protection\n'
                      '• 24/7 customer support\n'
                      '• PCI DSS compliant',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Security Notice
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your payment is secured by Razorpay\'s enterprise-grade security',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
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
