import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../payment/domain/models/payment.dart';
import '../../data/datasources/payment_remote_ds.dart';

class PaymentController extends AsyncNotifier<Payment?> {
  @override
  Payment? build() => null;

  Future<void> initiatePayment(
      String jobId, String phoneNumber, double amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(paymentRemoteDsProvider)
          .initiatePayment(jobId, phoneNumber, amount),
    );
  }

  Future<void> checkPaymentStatus(String jobId) async {
    state = await AsyncValue.guard(
      () => ref.read(paymentRemoteDsProvider).getPaymentByJobId(jobId),
    );
  }
}

final paymentControllerProvider =
    AsyncNotifierProvider<PaymentController, Payment?>(
        () => PaymentController());
