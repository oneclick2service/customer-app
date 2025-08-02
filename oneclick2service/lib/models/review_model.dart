import 'package:flutter/material.dart';

class Review {
  final String id;
  final String providerId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final int rating;
  final String comment;
  final Map<String, int> aspectRatings;
  final int helpfulCount;
  final bool isHelpful;
  final bool isReported;
  final String? providerResponse;
  final DateTime? providerResponseDate;
  final List<String>? providerResponseAttachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.rating,
    required this.comment,
    required this.aspectRatings,
    required this.helpfulCount,
    required this.isHelpful,
    required this.isReported,
    this.providerResponse,
    this.providerResponseDate,
    this.providerResponseAttachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userProfileImage: json['user_profile_image'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      aspectRatings: Map<String, int>.from(json['aspect_ratings'] ?? {}),
      helpfulCount: json['helpful_count'] as int? ?? 0,
      isHelpful: json['is_helpful'] as bool? ?? false,
      isReported: json['is_reported'] as bool? ?? false,
      providerResponse: json['provider_response'] as String?,
      providerResponseDate: json['provider_response_date'] != null
          ? DateTime.parse(json['provider_response_date'] as String)
          : null,
      providerResponseAttachments: json['provider_response_attachments'] != null
          ? List<String>.from(json['provider_response_attachments'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'user_id': userId,
      'user_name': userName,
      'user_profile_image': userProfileImage,
      'rating': rating,
      'comment': comment,
      'aspect_ratings': aspectRatings,
      'helpful_count': helpfulCount,
      'is_helpful': isHelpful,
      'is_reported': isReported,
      'provider_response': providerResponse,
      'provider_response_date': providerResponseDate?.toIso8601String(),
      'provider_response_attachments': providerResponseAttachments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? providerId,
    String? userId,
    String? userName,
    String? userProfileImage,
    int? rating,
    String? comment,
    Map<String, int>? aspectRatings,
    int? helpfulCount,
    bool? isHelpful,
    bool? isReported,
    String? providerResponse,
    DateTime? providerResponseDate,
    List<String>? providerResponseAttachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      aspectRatings: aspectRatings ?? this.aspectRatings,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isHelpful: isHelpful ?? this.isHelpful,
      isReported: isReported ?? this.isReported,
      providerResponse: providerResponse ?? this.providerResponse,
      providerResponseDate: providerResponseDate ?? this.providerResponseDate,
      providerResponseAttachments:
          providerResponseAttachments ?? this.providerResponseAttachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasProviderResponse =>
      providerResponse != null && providerResponse!.isNotEmpty;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String get ratingText {
    if (rating >= 4) return 'Excellent';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Average';
    return 'Poor';
  }
}
