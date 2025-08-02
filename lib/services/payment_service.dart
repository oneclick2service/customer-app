import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';

enum PaymentMethod { razorpay, upiIntent, card, wallet }

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Payment method constants
  static const String PAYMENT_METHOD_UPI = 'upi';
  static const String PAYMENT_METHOD_CARD = 'card';
  static const String PAYMENT_METHOD_WALLET = 'wallet';
  static const String PAYMENT_METHOD_RAZORPAY = 'razorpay';

  Razorpay? _razorpay;
  bool _isRazorpayInitialized = false;

  // Initialize Razorpay
  void initializeRazorpay() {
    if (_isRazorpayInitialized) return;

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _isRazorpayInitialized = true;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  // Dispose Razorpay
  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _isRazorpayInitialized = false;
  }

  // Razorpay Payment
  Future<Map<String, dynamic>> processRazorpayPayment({
    required BookingModel booking,
    required double amount,
    required String currency,
    required String userEmail,
    required String userPhone,
    required String userName,
  }) async {
    try {
      initializeRazorpay();

      final options = {
        'key': 'rzp_test_YOUR_KEY_HERE', // Replace with your Razorpay test key
        'amount': (amount * 100).toInt(), // Amount in paise
        'currency': currency,
        'name': 'OneClick2Service',
        'description': 'Booking ${booking.id}',
        'timeout': 180, // 3 minutes
        'prefill': {'contact': userPhone, 'email': userEmail, 'name': userName},
        'external': {
          'wallets': ['paytm', 'phonepe', 'gpay'],
        },
      };

      _razorpay!.open(options);

      return {
        'success': true,
        'message': 'Payment initiated',
        'method': 'razorpay',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to initiate payment: $e',
        'method': 'razorpay',
      };
    }
  }

  // Generate UPI URL
  String generateUpiUrl({
    required String payeeVpa,
    required double amount,
    required String transactionNote,
    required String merchantName,
  }) {
    final params = {
      'pa': payeeVpa, // Payee VPA
      'pn': merchantName, // Payee name
      'tn': transactionNote, // Transaction note
      'am': amount.toStringAsFixed(2), // Amount
      'cu': 'INR', // Currency
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'upi://pay?$queryString';
  }

  // Validate UPI ID
  bool isValidUPI(String upiId) {
    final upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]{3,}$');
    return upiRegex.hasMatch(upiId);
  }

  // Get available UPI apps
  List<String> getAvailableUPIApps() {
    return ['Google Pay', 'Paytm', 'PhonePe', 'Amazon Pay', 'BHIM', 'MobiKwik'];
  }

  // Get available wallets
  List<String> getAvailableWallets() {
    return [
      'Paytm',
      'PhonePe',
      'Google Pay',
      'Amazon Pay',
      'MobiKwik',
      'Freecharge',
    ];
  }

  // Process UPI Payment
  Future<PaymentResult> processUPIPayment({
    required BookingModel booking,
    required double amount,
    required String upiId,
  }) async {
    try {
      final upiUrl = generateUpiUrl(
        payeeVpa: upiId,
        amount: amount,
        transactionNote: 'Booking ${booking.id}',
        merchantName: 'OneClick2Service',
      );

      final uri = Uri.parse(upiUrl);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return PaymentResult(
          success: true,
          paymentMethod: PAYMENT_METHOD_UPI,
          amount: amount,
          currency: 'INR',
          timestamp: DateTime.now(),
        );
      } else {
        return PaymentResult(
          success: false,
          errorMessage: 'No UPI app found on device',
          paymentMethod: PAYMENT_METHOD_UPI,
          amount: amount,
          currency: 'INR',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Failed to process UPI payment: $e',
        paymentMethod: PAYMENT_METHOD_UPI,
        amount: amount,
        currency: 'INR',
        timestamp: DateTime.now(),
      );
    }
  }

  // Process Card Payment
  Future<PaymentResult> processCardPayment({
    required BookingModel booking,
    required double amount,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      // Simulate card payment processing
      await Future.delayed(Duration(seconds: 2));

      return PaymentResult(
        success: true,
        paymentId: generateTransactionId(),
        transactionId: generateTransactionId(),
        paymentMethod: PAYMENT_METHOD_CARD,
        amount: amount,
        currency: 'INR',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Failed to process card payment: $e',
        paymentMethod: PAYMENT_METHOD_CARD,
        amount: amount,
        currency: 'INR',
        timestamp: DateTime.now(),
      );
    }
  }

  // Process Wallet Payment
  Future<PaymentResult> processWalletPayment({
    required BookingModel booking,
    required double amount,
    required String walletType,
  }) async {
    try {
      // Simulate wallet payment processing
      await Future.delayed(Duration(seconds: 2));

      return PaymentResult(
        success: true,
        paymentId: generateTransactionId(),
        transactionId: generateTransactionId(),
        paymentMethod: PAYMENT_METHOD_WALLET,
        amount: amount,
        currency: 'INR',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Failed to process wallet payment: $e',
        paymentMethod: PAYMENT_METHOD_WALLET,
        amount: amount,
        currency: 'INR',
        timestamp: DateTime.now(),
      );
    }
  }

  // Get Payment History
  Future<List<PaymentRecord>> getPaymentHistory() async {
    // Simulate fetching payment history
    await Future.delayed(Duration(seconds: 1));

    return [
      PaymentRecord(
        id: '1',
        bookingId: 'booking_1',
        userId: 'user_1',
        amount: 500.0,
        currency: 'INR',
        paymentMethod: PAYMENT_METHOD_UPI,
        status: 'completed',
        transactionId: 'TXN123456',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
        processedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }

  // Generate Receipt
  Future<String> generateReceipt(PaymentRecord payment) async {
    // Simulate receipt generation
    await Future.delayed(Duration(seconds: 1));

    return '''
Receipt
========
Transaction ID: ${payment.transactionId}
Amount: ₹${payment.amount}
Payment Method: ${payment.paymentMethod}
Date: ${payment.createdAt.toString()}
Status: ${payment.status}
    ''';
  }

  // Update Payment Status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      // Simulate updating payment status
      await Future.delayed(Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Generate transaction ID
  String generateTransactionId() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch}';
  }

  // Format amount for display
  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Validate card number using Luhn algorithm
  bool validateCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s'), '');

    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }

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

    return sum % 10 == 0;
  }

  // Get card type from number
  String getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s'), '');

    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5')) {
      return 'Mastercard';
    } else if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      return 'American Express';
    } else if (cleanNumber.startsWith('6')) {
      return 'Discover';
    } else if (cleanNumber.startsWith('35')) {
      return 'JCB';
    } else {
      return 'Unknown';
    }
  }

  // Validate CVV
  bool validateCvv(String cvv, String cardType) {
    if (cardType == 'American Express') {
      return cvv.length == 4;
    } else {
      return cvv.length == 3;
    }
  }

  // Validate expiry date
  bool validateExpiryDate(String expiryDate) {
    try {
      final parts = expiryDate.split('/');
      if (parts.length != 2) return false;

      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}');

      if (month < 1 || month > 12) return false;

      final now = DateTime.now();
      final expiry = DateTime(year, month);

      return expiry.isAfter(now);
    } catch (e) {
      return false;
    }
  }
}
