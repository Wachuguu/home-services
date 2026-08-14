import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/payment.dart';
import '../../data/datasources/payment_remote_ds.dart';

part 'payment_controller.g.dart';

@riverpod
class PaymentController extends _$PaymentController {
  @override
  FutureOr<Payment?> build() {
    return null;
  }

  Future<void> initiatePayment(String jobId, String phoneNumber, double amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await ref.read(paymentRemoteDsProvider).initiatePayment(jobId, phoneNumber, amount);
    });
  }

  Future<void> checkPaymentStatus(String jobId) async {
    state = await AsyncValue.guard(() async {
      return await ref.read(paymentRemoteDsProvider).getPaymentByJobId(jobId);
    });
  }
}
