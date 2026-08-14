import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';

class ProviderMatchCard extends StatelessWidget {
  const ProviderMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: AppColors.backgroundElevated, child: Icon(Icons.person)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('John Smith', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 4),
                        Icon(Icons.verified, color: AppColors.primaryBlueLight, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        const Text('4.9 (120 reviews)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('2.5 km', style: TextStyle(color: AppColors.primaryBlueLight, fontWeight: FontWeight.bold)),
                  Text('away', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GradientButton(
            text: 'Select Provider',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
