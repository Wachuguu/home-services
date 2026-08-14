import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';

class MpesaPromptDialog extends StatelessWidget {
  final double amount;
  const MpesaPromptDialog({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_android, size: 64, color: AppColors.mPesaGreen)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms)
              .scaleXY(end: 1.1, duration: 800.ms)
              .then()
              .scaleXY(end: 1.0, duration: 800.ms),
          const SizedBox(height: 24),
          const Text(
            'Check your phone',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We have sent an M-Pesa prompt to your phone. Enter your PIN to pay KES ${amount.toStringAsFixed(0)}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(color: AppColors.mPesaGreen),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
