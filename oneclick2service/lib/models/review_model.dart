import 'package:flutter/material.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String userId;
  final String providerId;
  final String? userName;
  final String? userAvatar;
  final double rating;
  final String? comment;
  final List<String>? tags;
  final Map<String, double>? categoryRatings;
  final bool isAnonymous;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? reply;
  final DateTime? replyDate;
  final String? replyBy;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.providerId,
    this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    this.tags,
    this.categoryRatings,
    this.isAnonymous = false,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.reply,
    this.replyDate,
    this.replyBy,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      userId: json['user_id'] as String,
      providerId: json['provider_id'] as String,
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      categoryRatings: json['category_ratings'] != null
          ? Map<String, double>.from(
              (json['category_ratings'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ),
            )
          : null,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      reply: json['reply'] as String?,
      replyDate: json['reply_date'] != null
          ? DateTime.parse(json['reply_date'] as String)
          : null,
      replyBy: json['reply_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'provider_id': providerId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'category_ratings': categoryRatings,
      'is_anonymous': isVerified,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'reply': reply,
      'reply_date': replyDate?.toIso8601String(),
      'reply_by': replyBy,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? providerId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    List<String>? tags,
    Map<String, double>? categoryRatings,
    bool? isAnonymous,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reply,
    DateTime? replyDate,
    String? replyBy,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reply: reply ?? this.reply,
      replyDate: replyDate ?? this.replyDate,
      replyBy: replyBy ?? this.replyBy,
    );
  }

  String get displayName {
    if (isAnonymous) {
      return 'Anonymous User';
    }
    return userName ?? 'User';
  }

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

  bool get hasReply => reply != null && reply!.isNotEmpty;

  double get averageCategoryRating {
    if (categoryRatings == null || categoryRatings!.isEmpty) {
      return rating;
    }

    final total = categoryRatings!.values.reduce((a, b) => a + b);
    return total / categoryRatings!.length;
  }

  List<String> get categoryNames {
    return categoryRatings?.keys.toList() ?? [];
  }

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 30;
  }

  String get ratingText {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Average';
    if (rating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  Color get ratingColor {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }
}
