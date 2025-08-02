import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/booking_model.dart';

class CardPaymentScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const CardPaymentScreen({
    Key? key,
    required this.booking,
    required this.amount,
  }) : super(key: key);

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardholderNameController =
      TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;
  bool _isPaymentCompleted = false;
  String? _transactionId;
  String _cardType = 'unknown';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _detectCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s'), '');

    if (cleanNumber.startsWith('4')) {
      setState(() => _cardType = 'visa');
    } else if (cleanNumber.startsWith('5')) {
      setState(() => _cardType = 'mastercard');
    } else if (cleanNumber.startsWith('6')) {
      setState(() => _cardType = 'discover');
    } else if (cleanNumber.startsWith('3')) {
      setState(() => _cardType = 'amex');
    } else {
      setState(() => _cardType = 'unknown');
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    final cleanNumber = value.replaceAll(RegExp(r'\s'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Invalid card number length';
    }

    // Luhn algorithm validation
    int sum = 0;
    bool isEven = false;

    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    if (sum % 10 != 0) {
      return 'Invalid card number';
    }

    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Use MM/YY format';
    }

    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }

    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Invalid CVV';
    }

    return null;
  }

  void _formatCardNumber(String value) {
    final cleanNumber = value.replaceAll(RegExp(r'\s'), '');
    final formatted = cleanNumber
        .replaceAllMapped(RegExp(r'(\d{4})'), (match) => '${match.group(1)} ')
        .trim();

    if (formatted != value) {
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _formatExpiry(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';

    if (cleanValue.length >= 1) {
      formatted += cleanValue.substring(0, 1);
    }
    if (cleanValue.length >= 2) {
      formatted += cleanValue.substring(1, 2) + '/';
    }
    if (cleanValue.length >= 3) {
      formatted += cleanValue.substring(2, 3);
    }
    if (cleanValue.length >= 4) {
      formatted += cleanValue.substring(3, 4);
    }

    if (formatted != value) {
      _expiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Generate transaction ID
    final transactionId = 'CARD${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _transactionId = transactionId;
      _isPaymentCompleted = true;
      _isLoading = false;
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
            Text(
              'Card: **** **** **** ${_cardNumberController.text.split(' ').last}',
            ),
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

  IconData _getCardIcon() {
    switch (_cardType) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'discover':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card_outlined;
    }
  }

  Color _getCardColor() {
    switch (_cardType) {
      case 'visa':
        return Colors.blue;
      case 'mastercard':
        return Colors.orange;
      case 'discover':
        return Colors.red;
      case 'amex':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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

              // Card Information
              const Text(
                'Card Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Card Number
              CustomTextField(
                controller: _cardNumberController,
                hintText: 'Card Number',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(_getCardIcon(), color: _getCardColor()),
                validator: _validateCardNumber,
                onChanged: (value) {
                  _formatCardNumber(value);
                  _detectCardType(value);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                ],
              ),
              const SizedBox(height: 16),

              // Cardholder Name
              CustomTextField(
                controller: _cardholderNameController,
                hintText: 'Cardholder Name',
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cardholder name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry and CVV Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _expiryController,
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: _validateExpiry,
                      onChanged: _formatExpiry,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _cvvController,
                      hintText: 'CVV',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: _validateCvv,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Security Notice
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your payment information is encrypted and secure.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pay Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _isLoading || _isPaymentCompleted
                      ? null
                      : _processPayment,
                  text: _isLoading
                      ? 'Processing Payment...'
                      : _isPaymentCompleted
                      ? 'Payment Completed'
                      : 'Pay ₹${_amountController.text}',
                ),
              ),

              if (_isPaymentCompleted) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Payment Successful',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
