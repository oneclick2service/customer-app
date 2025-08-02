import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking_model.dart';

enum PaymentMethod { razorpay, upiIntent, card, wallet }

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

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

  // Intent-based UPI Payment
  Future<Map<String, dynamic>> processUpiIntentPayment({
    required BookingModel booking,
    required double amount,
    required String upiId,
  }) async {
    try {
      // Generate UPI payment URL
      final upiUrl = _generateUpiUrl(
        payeeVpa: upiId,
        amount: amount,
        transactionNote: 'Booking ${booking.id}',
        merchantName: 'OneClick2Service',
      );

      // Launch UPI intent
      final uri = Uri.parse(upiUrl);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        return {
          'success': true,
          'message': 'UPI payment intent launched',
          'method': 'upi_intent',
          'upiUrl': upiUrl,
        };
      } else {
        return {
          'success': false,
          'message': 'No UPI app found on device',
          'method': 'upi_intent',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to launch UPI intent: $e',
        'method': 'upi_intent',
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
  bool validateUpiId(String upiId) {
    final upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]{3,}$');
    return upiRegex.hasMatch(upiId);
  }

  // Get available UPI apps
  Future<List<String>> getAvailableUpiApps() async {
    // Common UPI apps in India
    final upiApps = [
      'com.google.android.apps.nbu.paisa.user', // Google Pay
      'net.one97.paytm', // Paytm
      'in.amazonpay', // Amazon Pay
      'com.phonepe.app', // PhonePe
      'com.mobikwik_new', // MobiKwik
      'com.axis.bank.android', // Axis Bank
      'com.hdfcbank.hdfcbankmobile', // HDFC Bank
      'com.icici.bank.imobile', // ICICI Bank
    ];

    final availableApps = <String>[];

    for (final app in upiApps) {
      try {
        final uri = Uri.parse('$app://');
        if (await canLaunchUrl(uri)) {
          availableApps.add(app);
        }
      } catch (e) {
        // App not available
      }
    }

    return availableApps;
  }

  // Launch specific UPI app
  Future<bool> launchUpiApp(String packageName, String upiUrl) async {
    try {
      final uri = Uri.parse('$packageName://upi/pay?$upiUrl');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
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
