class ServiceProviderModel {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? profileImage;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? pincode;
  final List<String> serviceCategories;
  final List<String> specializations;
  final double rating;
  final int totalReviews;
  final int totalBookings;
  final int completedBookings;
  final bool isAvailable;
  final bool isVerified;
  final bool isBackgroundChecked;
  final String? experience;
  final String? certifications;
  final double? hourlyRate;
  final double? basePrice;
  final String? bio;
  final List<String>? images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActive;

  ServiceProviderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.profileImage,
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.pincode,
    required this.serviceCategories,
    required this.specializations,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.isAvailable = true,
    this.isVerified = false,
    this.isBackgroundChecked = false,
    this.experience,
    this.certifications,
    this.hourlyRate,
    this.basePrice,
    this.bio,
    this.images,
    required this.createdAt,
    required this.updatedAt,
    this.lastActive,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      profileImage: json['profile_image'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      serviceCategories: List<String>.from(json['service_categories'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      completedBookings: json['completed_bookings'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      isVerified: json['is_verified'] ?? false,
      isBackgroundChecked: json['is_background_checked'] ?? false,
      experience: json['experience'],
      certifications: json['certifications'],
      hourlyRate: json['hourly_rate']?.toDouble(),
      basePrice: json['base_price']?.toDouble(),
      bio: json['bio'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastActive: json['last_active'] != null ? DateTime.parse(json['last_active']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'profile_image': profileImage,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'pincode': pincode,
      'service_categories': serviceCategories,
      'specializations': specializations,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_bookings': totalBookings,
      'completed_bookings': completedBookings,
      'is_available': isAvailable,
      'is_verified': isVerified,
      'is_background_checked': isBackgroundChecked,
      'experience': experience,
      'certifications': certifications,
      'hourly_rate': hourlyRate,
      'base_price': basePrice,
      'bio': bio,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_active': lastActive?.toIso8601String(),
    };
  }

  ServiceProviderModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phoneNumber,
    String? email,
    String? profileImage,
    String? address,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? pincode,
    List<String>? serviceCategories,
    List<String>? specializations,
    double? rating,
    int? totalReviews,
    int? totalBookings,
    int? completedBookings,
    bool? isAvailable,
    bool? isVerified,
    bool? isBackgroundChecked,
    String? experience,
    String? certifications,
    double? hourlyRate,
    double? basePrice,
    String? bio,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
  }) {
    return ServiceProviderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      specializations: specializations ?? this.specializations,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      isBackgroundChecked: isBackgroundChecked ?? this.isBackgroundChecked,
      experience: experience ?? this.experience,
      certifications: certifications ?? this.certifications,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      basePrice: basePrice ?? this.basePrice,
      bio: bio ?? this.bio,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() {
    return 'ServiceProviderModel(id: $id, name: $name, phoneNumber: $phoneNumber, serviceCategories: $serviceCategories, rating: $rating, isAvailable: $isAvailable, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceProviderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 