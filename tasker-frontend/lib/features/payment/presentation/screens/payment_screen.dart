import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../../jobs/presentation/screens/job_detail_screen.dart';
import '../controllers/payment_controller.dart';
import '../widgets/mpesa_prompt_dialog.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String jobId;
  const PaymentScreen({super.key, required this.jobId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _phoneController = TextEditingController(text: '254700000000');
  bool _isProcessing = false;

  Future<void> _pay(double amount) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid phone number'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await ref
          .read(paymentControllerProvider.notifier)
          .initiatePayment(widget.jobId, phone, amount);

      if (mounted) setState(() => _isProcessing = false);

      if (mounted) {
        // Show M-Pesa prompt dialog and wait for it to close
        await showModalBottomSheet(
          context: context,
          isDismissible: false,
          backgroundColor: Colors.transparent,
          builder: (ctx) => MpesaPromptDialog(amount: amount),
        );

        // After dialog closes, refresh job detail and go back
        ref.invalidate(jobDetailProvider(widget.jobId));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment failed: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));

    return AppScaffold(
      appBar: const GradientAppBar(title: 'Payment'),
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child:
              Text('$e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (job) {
          final amount = job.estimatedCost;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Job info summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(job.categoryName,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Amount card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.mPesaGreen.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Text(
                        'KES ${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Phone input
                AuthTextField(
                  controller: _phoneController,
                  label: 'M-Pesa Number',
                  hint: '254...',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),

                // Pay button
                GradientButton(
                  text: 'Pay via M-Pesa',
                  gradient: const LinearGradient(
                      colors: [AppColors.mPesaGreen, Color(0xFF007A3B)]),
                  isLoading: _isProcessing,
                  onPressed: () => _pay(amount),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
