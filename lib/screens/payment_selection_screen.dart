import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/booking_model.dart';
import '../services/payment_service.dart';
import 'razorpay_payment_screen.dart';
import 'upi_payment_screen.dart';
import 'card_payment_screen.dart';
import 'digital_wallet_screen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const PaymentSelectionScreen({
    Key? key,
    required this.booking,
    required this.amount,
  }) : super(key: key);

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  final PaymentService _paymentService = PaymentService();
  PaymentMethod _selectedMethod = PaymentMethod.razorpay;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paymentService.initializeRazorpay();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _proceedToPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      switch (_selectedMethod) {
        case PaymentMethod.razorpay:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RazorpayPaymentScreen(
                booking: widget.booking,
                amount: widget.amount,
              ),
            ),
          );
          break;

        case PaymentMethod.upiIntent:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpiPaymentScreen(
                booking: widget.booking,
                amount: widget.amount,
              ),
            ),
          );
          break;

        case PaymentMethod.card:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardPaymentScreen(
                booking: widget.booking,
                amount: widget.amount,
              ),
            ),
          );
          break;

        case PaymentMethod.wallet:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DigitalWalletScreen(
                booking: widget.booking,
                amount: widget.amount,
              ),
            ),
          );
          break;
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPaymentMethodCard({
    required PaymentMethod method,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == method;

    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? color.withOpacity(0.1) : Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Payment Method'),
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
                    const Text(
                      'Payment Summary',
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

            // Payment Methods
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Razorpay Option
            _buildPaymentMethodCard(
              method: PaymentMethod.razorpay,
              title: 'Razorpay (Recommended)',
              description: 'Complete payment gateway with UPI, cards, wallets',
              icon: Icons.payment,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            // UPI Intent Option
            _buildPaymentMethodCard(
              method: PaymentMethod.upiIntent,
              title: 'UPI Intent (Direct)',
              description: 'Direct integration with UPI apps',
              icon: Icons.qr_code,
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            // Card Payment Option
            _buildPaymentMethodCard(
              method: PaymentMethod.card,
              title: 'Credit/Debit Card',
              description: 'Pay with Visa, Mastercard, or other cards',
              icon: Icons.credit_card,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),

            // Digital Wallet Option
            _buildPaymentMethodCard(
              method: PaymentMethod.wallet,
              title: 'Digital Wallet',
              description: 'Pay with Paytm, PhonePe, Google Pay, etc.',
              icon: Icons.account_balance_wallet,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),

            // Payment Method Details
            if (_selectedMethod == PaymentMethod.razorpay) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Razorpay Benefits',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Secure payment processing\n'
                        '• Multiple payment options\n'
                        '• Real-time transaction status\n'
                        '• Built-in security features\n'
                        '• 24/7 customer support',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_selectedMethod == PaymentMethod.upiIntent) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'UPI Intent Benefits',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Direct UPI app integration\n'
                        '• Lower transaction costs\n'
                        '• Instant payment processing\n'
                        '• Works with all UPI apps\n'
                        '• No additional dependencies',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _isLoading ? null : _proceedToPayment,
                text: _isLoading ? 'Processing...' : 'Proceed to Payment',
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
                        'Your payment information is secure and encrypted',
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
