class BookingModel {
  final String id;
  final String customerId;
  final String? serviceProviderId;
  final String serviceCategory;
  final String serviceType;
  final String description;
  final String status;
  final double amount;
  final String paymentMethod;
  final bool isPaid;
  final String? customerAddress;
  final double? customerLatitude;
  final double? customerLongitude;
  final DateTime scheduledDate;
  final DateTime? actualDate;
  final DateTime? providerArrivalTime;
  final DateTime? serviceStartTime;
  final DateTime? serviceEndTime;
  final int? estimatedDuration; // in minutes
  final String? specialInstructions;
  final List<String>? mediaUrls; // photos/videos
  final String? audioUrl;
  final double? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? cancelledBy;

  BookingModel({
    required this.id,
    required this.customerId,
    this.serviceProviderId,
    required this.serviceCategory,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.amount,
    required this.paymentMethod,
    this.isPaid = false,
    this.customerAddress,
    this.customerLatitude,
    this.customerLongitude,
    required this.scheduledDate,
    this.actualDate,
    this.providerArrivalTime,
    this.serviceStartTime,
    this.serviceEndTime,
    this.estimatedDuration,
    this.specialInstructions,
    this.mediaUrls,
    this.audioUrl,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
    this.cancellationReason,
    this.cancelledAt,
    this.cancelledBy,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      serviceProviderId: json['service_provider_id'],
      serviceCategory: json['service_category'] ?? '',
      serviceType: json['service_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      isPaid: json['is_paid'] ?? false,
      customerAddress: json['customer_address'],
      customerLatitude: json['customer_latitude']?.toDouble(),
      customerLongitude: json['customer_longitude']?.toDouble(),
      scheduledDate: DateTime.parse(json['scheduled_date']),
      actualDate: json['actual_date'] != null ? DateTime.parse(json['actual_date']) : null,
      providerArrivalTime: json['provider_arrival_time'] != null ? DateTime.parse(json['provider_arrival_time']) : null,
      serviceStartTime: json['service_start_time'] != null ? DateTime.parse(json['service_start_time']) : null,
      serviceEndTime: json['service_end_time'] != null ? DateTime.parse(json['service_end_time']) : null,
      estimatedDuration: json['estimated_duration'],
      specialInstructions: json['special_instructions'],
      mediaUrls: json['media_urls'] != null ? List<String>.from(json['media_urls']) : null,
      audioUrl: json['audio_url'],
      rating: json['rating']?.toDouble(),
      review: json['review'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      cancellationReason: json['cancellation_reason'],
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      cancelledBy: json['cancelled_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_provider_id': serviceProviderId,
      'service_category': serviceCategory,
      'service_type': serviceType,
      'description': description,
      'status': status,
      'amount': amount,
      'payment_method': paymentMethod,
      'is_paid': isPaid,
      'customer_address': customerAddress,
      'customer_latitude': customerLatitude,
      'customer_longitude': customerLongitude,
      'scheduled_date': scheduledDate.toIso8601String(),
      'actual_date': actualDate?.toIso8601String(),
      'provider_arrival_time': providerArrivalTime?.toIso8601String(),
      'service_start_time': serviceStartTime?.toIso8601String(),
      'service_end_time': serviceEndTime?.toIso8601String(),
      'estimated_duration': estimatedDuration,
      'special_instructions': specialInstructions,
      'media_urls': mediaUrls,
      'audio_url': audioUrl,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancelled_by': cancelledBy,
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? serviceProviderId,
    String? serviceCategory,
    String? serviceType,
    String? description,
    String? status,
    double? amount,
    String? paymentMethod,
    bool? isPaid,
    String? customerAddress,
    double? customerLatitude,
    double? customerLongitude,
    DateTime? scheduledDate,
    DateTime? actualDate,
    DateTime? providerArrivalTime,
    DateTime? serviceStartTime,
    DateTime? serviceEndTime,
    int? estimatedDuration,
    String? specialInstructions,
    List<String>? mediaUrls,
    String? audioUrl,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    DateTime? cancelledAt,
    String? cancelledBy,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      customerAddress: customerAddress ?? this.customerAddress,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      actualDate: actualDate ?? this.actualDate,
      providerArrivalTime: providerArrivalTime ?? this.providerArrivalTime,
      serviceStartTime: serviceStartTime ?? this.serviceStartTime,
      serviceEndTime: serviceEndTime ?? this.serviceEndTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
    );
  }

  @override
  String toString() {
    return 'BookingModel(id: $id, customerId: $customerId, serviceProviderId: $serviceProviderId, serviceCategory: $serviceCategory, status: $status, amount: $amount, scheduledDate: $scheduledDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 