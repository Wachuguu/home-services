class Skill {
  final int categoryId;
  final String categoryName;
  final int? experienceYears;
  final double? hourlyRate;
  final bool verified;

  Skill({
    required this.categoryId,
    required this.categoryName,
    this.experienceYears,
    this.hourlyRate,
    this.verified = false,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      experienceYears: json['experienceYears'],
      hourlyRate: json['hourlyRate']?.toDouble(),
      verified: json['verified'] ?? false,
    );
  }
}

class User {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool? isAvailable;
  final double? rating;
  final int? totalReviews;
  final List<Skill>? skills;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.latitude,
    this.longitude,
    this.address,
    this.isAvailable,
    this.rating,
    this.totalReviews,
    this.skills,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      isAvailable: json['isAvailable'],
      rating: json['rating']?.toDouble(),
      totalReviews: json['totalReviews'],
      skills: (json['skills'] as List?)
          ?.map((e) => Skill.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isAvailable': isAvailable,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }
}
