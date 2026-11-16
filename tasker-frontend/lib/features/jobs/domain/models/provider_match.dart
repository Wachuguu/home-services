class ProviderMatch {
  final String providerId;
  final String fullName;
  final String phoneNumber;
  final double distanceKm;
  final double rating;
  final int totalReviews;
  final double? hourlyRate;
  final int? experienceYears;
  final bool verified;
  final String? profileImageUrl;

  const ProviderMatch({
    required this.providerId,
    required this.fullName,
    required this.phoneNumber,
    required this.distanceKm,
    required this.rating,
    required this.totalReviews,
    this.hourlyRate,
    this.experienceYears,
    this.verified = false,
    this.profileImageUrl,
  });

  String get id => providerId;

  factory ProviderMatch.fromJson(Map<String, dynamic> json) {
    return ProviderMatch(
      providerId: json['providerId']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
      verified: json['verified'] ?? false,
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'distanceKm': distanceKm,
      'rating': rating,
      'totalReviews': totalReviews,
      'hourlyRate': hourlyRate,
      'experienceYears': experienceYears,
      'verified': verified,
      'profileImageUrl': profileImageUrl,
    };
  }
}
