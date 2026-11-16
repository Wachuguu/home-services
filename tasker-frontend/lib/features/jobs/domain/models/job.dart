class Job {
  final String id;
  final String clientId;
  final String clientName;
  final String? providerId;
  final String? providerName;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final String status;
  final double latitude;
  final double longitude;
  final String address;
  final double estimatedCost;
  final double? finalCost;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.providerId,
    this.providerName,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.estimatedCost,
    this.finalCost,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      providerId: json['providerId'],
      providerName: json['providerName'],
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'REQUESTED',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      finalCost: json['finalCost']?.toDouble(),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
