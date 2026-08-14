import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import 'widgets/mpesa_prompt_dialog.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String jobId;
  const PaymentScreen({super.key, required this.jobId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _phoneController = TextEditingController(text: '254700000000');

  void _pay() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const MpesaPromptDialog(amount: 1500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const GradientAppBar(title: 'Payment'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mPesaGreen.withOpacity(0.5)),
              ),
              child: const Column(
                children: [
                  Text('Total Amount', style: TextStyle(color: AppColors.textMuted)),
                  SizedBox(height: 8),
                  Text('KES 1,500', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AuthTextField(
              controller: _phoneController,
              label: 'M-Pesa Number',
              hint: '254...',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Pay via M-Pesa',
              gradient: const LinearGradient(colors: [AppColors.mPesaGreen, Color(0xFF007A3B)]),
              onPressed: _pay,
            ),
          ],
        ),
      ),
    );
  }
}
