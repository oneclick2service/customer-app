class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? transactionId;
  final String? errorMessage;
  final String paymentMethod;
  final double amount;
  final String currency;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.transactionId,
    this.errorMessage,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    required this.timestamp,
    this.metadata,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'] ?? false,
      paymentId: json['payment_id'],
      transactionId: json['transaction_id'],
      errorMessage: json['error_message'],
      paymentMethod: json['payment_method'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'INR',
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payment_id': paymentId,
      'transaction_id': transactionId,
      'error_message': errorMessage,
      'payment_method': paymentMethod,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class PaymentRecord {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final String? paymentGateway;
  final String? gatewayTransactionId;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? processedAt;

  PaymentRecord({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.paymentGateway,
    this.gatewayTransactionId,
    this.errorMessage,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.processedAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'INR',
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      transactionId: json['transaction_id'],
      paymentGateway: json['payment_gateway'],
      gatewayTransactionId: json['gateway_transaction_id'],
      errorMessage: json['error_message'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
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
      'payment_gateway': paymentGateway,
      'gateway_transaction_id': gatewayTransactionId,
      'error_message': errorMessage,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }
}
