class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? profileImage;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? pincode;
  final bool isCorporate;
  final String? companyName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final double rating;
  final int totalBookings;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.profileImage,
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.pincode,
    this.isCorporate = false,
    this.companyName,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalBookings = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      isCorporate: json['is_corporate'] ?? false,
      companyName: json['company_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isVerified: json['is_verified'] ?? false,
      rating: json['rating']?.toDouble() ?? 0.0,
      totalBookings: json['total_bookings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_corporate': isCorporate,
      'company_name': companyName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_verified': isVerified,
      'rating': rating,
      'total_bookings': totalBookings,
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    String? profileImage,
    String? address,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? pincode,
    bool? isCorporate,
    String? companyName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    double? rating,
    int? totalBookings,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isCorporate: isCorporate ?? this.isCorporate,
      companyName: companyName ?? this.companyName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalBookings: totalBookings ?? this.totalBookings,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, phoneNumber: $phoneNumber, name: $name, email: $email, address: $address, isCorporate: $isCorporate, companyName: $companyName, isVerified: $isVerified, rating: $rating, totalBookings: $totalBookings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 