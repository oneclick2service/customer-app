import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Payment methods
  static const String PAYMENT_METHOD_UPI = 'upi';
  static const String PAYMENT_METHOD_CARD = 'card';
  static const String PAYMENT_METHOD_WALLET = 'wallet';
  static const String PAYMENT_METHOD_CASH = 'cash';

  // Payment status
  static const String PAYMENT_STATUS_PENDING = 'pending';
  static const String PAYMENT_STATUS_SUCCESS = 'success';
  static const String PAYMENT_STATUS_FAILED = 'failed';
  static const String PAYMENT_STATUS_REFUNDED = 'refunded';
  static const String PAYMENT_STATUS_DISPUTED = 'disputed';

  // UPI apps
  static const List<String> UPI_APPS = [
    'Google Pay',
    'PhonePe',
    'Paytm',
    'BHIM',
    'Amazon Pay',
    'WhatsApp Pay',
  ];

  // Digital wallets
  static const List<String> DIGITAL_WALLETS = [
    'Paytm',
    'PhonePe',
    'Google Pay',
    'Amazon Pay',
    'MobiKwik',
    'Freecharge',
  ];

  // Initialize payment service
  Future<void> initialize() async {
    // Setup any payment gateway configurations
    await _setupPaymentGateway();
  }

  // Setup payment gateway (mock implementation)
  Future<void> _setupPaymentGateway() async {
    // TODO: Initialize actual payment gateway SDK
    debugPrint('Payment gateway initialized');
  }

  // Process UPI payment
  Future<PaymentResult> processUPIPayment({
    required String bookingId,
    required double amount,
    required String upiId,
    String? upiApp,
    String? description,
  }) async {
    try {
      // Create payment record
      final paymentId = await _createPaymentRecord(
        bookingId: bookingId,
        amount: amount,
        method: PAYMENT_METHOD_UPI,
        metadata: {
          'upi_id': upiId,
          'upi_app': upiApp,
          'description': description,
        },
      );

      // Simulate UPI payment processing
      final result = await _simulateUPIPayment(upiId, amount, description);

      // Update payment record
      await _updatePaymentRecord(
        paymentId: paymentId,
        status: result.success ? PAYMENT_STATUS_SUCCESS : PAYMENT_STATUS_FAILED,
        transactionId: result.transactionId,
        metadata: result.metadata,
      );

      return result;
    } catch (e) {
      debugPrint('UPI payment error: $e');
      return PaymentResult(
        success: false,
        message: 'Payment failed: $e',
        transactionId: null,
        metadata: {},
      );
    }
  }

  // Process card payment
  Future<PaymentResult> processCardPayment({
    required String bookingId,
    required double amount,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
    String? description,
  }) async {
    try {
      // Create payment record
      final paymentId = await _createPaymentRecord(
        bookingId: bookingId,
        amount: amount,
        method: PAYMENT_METHOD_CARD,
        metadata: {
          'card_last4': cardNumber.substring(cardNumber.length - 4),
          'cardholder_name': cardholderName,
          'description': description,
        },
      );

      // Simulate card payment processing
      final result = await _simulateCardPayment(
        cardNumber,
        expiryDate,
        cvv,
        amount,
        description,
      );

      // Update payment record
      await _updatePaymentRecord(
        paymentId: paymentId,
        status: result.success ? PAYMENT_STATUS_SUCCESS : PAYMENT_STATUS_FAILED,
        transactionId: result.transactionId,
        metadata: result.metadata,
      );

      return result;
    } catch (e) {
      debugPrint('Card payment error: $e');
      return PaymentResult(
        success: false,
        message: 'Payment failed: $e',
        transactionId: null,
        metadata: {},
      );
    }
  }

  // Process digital wallet payment
  Future<PaymentResult> processWalletPayment({
    required String bookingId,
    required double amount,
    required String walletType,
    required String walletId,
    String? description,
  }) async {
    try {
      // Create payment record
      final paymentId = await _createPaymentRecord(
        bookingId: bookingId,
        amount: amount,
        method: PAYMENT_METHOD_WALLET,
        metadata: {
          'wallet_type': walletType,
          'wallet_id': walletId,
          'description': description,
        },
      );

      // Simulate wallet payment processing
      final result = await _simulateWalletPayment(
        walletType,
        walletId,
        amount,
        description,
      );

      // Update payment record
      await _updatePaymentRecord(
        paymentId: paymentId,
        status: result.success ? PAYMENT_STATUS_SUCCESS : PAYMENT_STATUS_FAILED,
        transactionId: result.transactionId,
        metadata: result.metadata,
      );

      return result;
    } catch (e) {
      debugPrint('Wallet payment error: $e');
      return PaymentResult(
        success: false,
        message: 'Payment failed: $e',
        transactionId: null,
        metadata: {},
      );
    }
  }

  // Create payment record in database
  Future<String> _createPaymentRecord({
    required String bookingId,
    required double amount,
    required String method,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final paymentData = {
        'booking_id': bookingId,
        'user_id': user.id,
        'amount': amount,
        'currency': 'INR',
        'payment_method': method,
        'status': PAYMENT_STATUS_PENDING,
        'metadata': metadata ?? {},
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('payments')
          .insert(paymentData)
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create payment record: $e');
    }
  }

  // Update payment record
  Future<void> _updatePaymentRecord({
    required String paymentId,
    required String status,
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (transactionId != null) {
        updateData['transaction_id'] = transactionId;
      }

      if (metadata != null) {
        updateData['metadata'] = metadata;
      }

      await _supabase.from('payments').update(updateData).eq('id', paymentId);
    } catch (e) {
      debugPrint('Error updating payment record: $e');
    }
  }

  // Public method to update payment status
  Future<void> updatePaymentStatus(
    String paymentId,
    String status,
    Map<String, dynamic>? metadata,
  ) async {
    await _updatePaymentRecord(
      paymentId: paymentId,
      status: status,
      metadata: metadata,
    );
  }

  // Simulate UPI payment (replace with actual UPI integration)
  Future<PaymentResult> _simulateUPIPayment(
    String upiId,
    double amount,
    String? description,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success/failure based on UPI ID format
    final isValidUPI = upiId.contains('@') && upiId.length > 5;

    if (isValidUPI) {
      return PaymentResult(
        success: true,
        message: 'Payment successful',
        transactionId: _generateTransactionId(),
        metadata: {
          'upi_id': upiId,
          'amount': amount,
          'description': description,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      return PaymentResult(
        success: false,
        message: 'Invalid UPI ID format',
        transactionId: null,
        metadata: {},
      );
    }
  }

  // Simulate card payment (replace with actual card payment integration)
  Future<PaymentResult> _simulateCardPayment(
    String cardNumber,
    String expiryDate,
    String cvv,
    double amount,
    String? description,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Basic card validation
    final isValidCard = _validateCard(cardNumber, expiryDate, cvv);

    if (isValidCard) {
      return PaymentResult(
        success: true,
        message: 'Payment successful',
        transactionId: _generateTransactionId(),
        metadata: {
          'card_last4': cardNumber.substring(cardNumber.length - 4),
          'amount': amount,
          'description': description,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      return PaymentResult(
        success: false,
        message: 'Invalid card details',
        transactionId: null,
        metadata: {},
      );
    }
  }

  // Simulate wallet payment (replace with actual wallet integration)
  Future<PaymentResult> _simulateWalletPayment(
    String walletType,
    String walletId,
    double amount,
    String? description,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success/failure based on wallet type
    final isValidWallet = DIGITAL_WALLETS.contains(walletType);

    if (isValidWallet) {
      return PaymentResult(
        success: true,
        message: 'Payment successful',
        transactionId: _generateTransactionId(),
        metadata: {
          'wallet_type': walletType,
          'wallet_id': walletId,
          'amount': amount,
          'description': description,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      return PaymentResult(
        success: false,
        message: 'Unsupported wallet type',
        transactionId: null,
        metadata: {},
      );
    }
  }

  // Validate card details
  bool _validateCard(String cardNumber, String expiryDate, String cvv) {
    // Basic validation
    if (cardNumber.length < 13 || cardNumber.length > 19) return false;
    if (cvv.length < 3 || cvv.length > 4) return false;

    // Validate expiry date format (MM/YY)
    final expiryRegex = RegExp(r'^\d{2}/\d{2}$');
    if (!expiryRegex.hasMatch(expiryDate)) return false;

    // Check if card is not expired
    final parts = expiryDate.split('/');
    final month = int.parse(parts[0]);
    final year = 2000 + int.parse(parts[1]);
    final expiry = DateTime(year, month);
    final now = DateTime.now();

    return expiry.isAfter(now);
  }

  // Generate transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TXN${timestamp}${random}';
  }

  // Get payment history
  Future<List<PaymentRecord>> getPaymentHistory({String? userId}) async {
    try {
      final user = userId ?? _supabase.auth.currentUser?.id;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('payments')
          .select()
          .eq('user_id', user)
          .order('created_at', ascending: false);

      return response.map((json) => PaymentRecord.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return [];
    }
  }

  // Get payment by ID
  Future<PaymentRecord?> getPaymentById(String paymentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('id', paymentId)
          .single();

      return PaymentRecord.fromJson(response);
    } catch (e) {
      debugPrint('Error getting payment: $e');
      return null;
    }
  }

  // Process refund
  Future<PaymentResult> processRefund({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      // Get original payment
      final payment = await getPaymentById(paymentId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      if (payment.status != PAYMENT_STATUS_SUCCESS) {
        throw Exception('Payment cannot be refunded');
      }

      // Simulate refund processing
      await Future.delayed(const Duration(seconds: 2));

      // Update payment status
      await _updatePaymentRecord(
        paymentId: paymentId,
        status: PAYMENT_STATUS_REFUNDED,
        metadata: {
          'refund_amount': amount,
          'refund_reason': reason,
          'refunded_at': DateTime.now().toIso8601String(),
        },
      );

      return PaymentResult(
        success: true,
        message: 'Refund processed successfully',
        transactionId: _generateTransactionId(),
        metadata: {
          'original_payment_id': paymentId,
          'refund_amount': amount,
          'reason': reason,
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Refund failed: $e',
        transactionId: null,
        metadata: {},
      );
    }
  }

  // Generate digital receipt
  Future<Map<String, dynamic>> generateReceipt(String paymentId) async {
    try {
      final payment = await getPaymentById(paymentId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      return {
        'receipt_id': 'RCP${DateTime.now().millisecondsSinceEpoch}',
        'payment_id': paymentId,
        'amount': payment.amount,
        'currency': payment.currency,
        'payment_method': payment.paymentMethod,
        'status': payment.status,
        'transaction_id': payment.transactionId,
        'created_at': payment.createdAt.toIso8601String(),
        'company_name': 'One Click 2 Service',
        'company_address': 'Vijayawada, Andhra Pradesh',
        'gst_number': 'GST123456789',
        'terms': 'Payment is non-refundable unless service is not provided',
      };
    } catch (e) {
      throw Exception('Failed to generate receipt: $e');
    }
  }

  // Validate UPI ID
  static bool isValidUPI(String upiId) {
    // Basic UPI validation
    final upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]{2,}$');
    return upiRegex.hasMatch(upiId);
  }

  // Get available UPI apps
  static List<String> getAvailableUPIApps() {
    return UPI_APPS;
  }

  // Get available digital wallets
  static List<String> getAvailableWallets() {
    return DIGITAL_WALLETS;
  }

  // Dispose resources
  void dispose() {
    // Cleanup any payment gateway resources
  }
}

// Payment result model
class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;
  final Map<String, dynamic> metadata;

  PaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
    this.metadata = const {},
  });
}

// Payment record model
class PaymentRecord {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentRecord({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>)
          : <String, dynamic>{},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'status': status,
      'transaction_id': transactionId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
