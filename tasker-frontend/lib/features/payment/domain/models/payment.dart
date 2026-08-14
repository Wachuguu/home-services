class Payment {
  final String id;
  final String jobId;
  final double amount;
  final String status;
  final String? mpesaReceiptNumber;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.jobId,
    required this.amount,
    required this.status,
    this.mpesaReceiptNumber,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      mpesaReceiptNumber: json['mpesaReceiptNumber'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
