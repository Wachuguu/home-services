import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/payment.dart';

final paymentRemoteDsProvider = Provider<PaymentRemoteDs>((ref) {
  return PaymentRemoteDs(ref.watch(dioClientProvider));
});

class PaymentRemoteDs {
  final Dio _dio;

  PaymentRemoteDs(this._dio);

  Future<Payment> initiatePayment(String jobId, String phoneNumber, double amount) async {
    final response = await _dio.post(ApiEndpoints.initiatePayment, data: {
      'jobId': jobId,
      'phoneNumber': phoneNumber,
      'amount': amount,
    });
    return Payment.fromJson(response.data);
  }

  Future<Payment> getPaymentByJobId(String jobId) async {
    final response = await _dio.get(ApiEndpoints.paymentByJobId(jobId));
    return Payment.fromJson(response.data);
  }
}
