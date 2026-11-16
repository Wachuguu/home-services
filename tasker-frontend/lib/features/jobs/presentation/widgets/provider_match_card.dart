import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../domain/models/provider_match.dart';

class ProviderMatchCard extends StatelessWidget {
  final ProviderMatch provider;
  final VoidCallback onSelect;
  final bool isLoading;

  const ProviderMatchCard({
    super.key,
    required this.provider,
    required this.onSelect,
    this.isLoading = false,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.backgroundElevated,
                backgroundImage: provider.profileImageUrl != null &&
                        provider.profileImageUrl!.isNotEmpty
                    ? NetworkImage(provider.profileImageUrl!)
                    : null,
                child: provider.profileImageUrl == null ||
                        provider.profileImageUrl!.isEmpty
                    ? Text(
                        provider.fullName.isNotEmpty
                            ? provider.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlueLight,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            provider.fullName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (provider.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              color: AppColors.primaryBlueLight, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.rating.toStringAsFixed(1)} (${provider.totalReviews} reviews)',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${provider.distanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                        color: AppColors.primaryBlueLight,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text('away',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
          if (provider.hourlyRate != null || provider.experienceYears != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (provider.hourlyRate != null)
                  Text(
                    'KES ${provider.hourlyRate!.toStringAsFixed(0)}/hr',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                if (provider.hourlyRate != null &&
                    provider.experienceYears != null)
                  const Text(' • ',
                      style: TextStyle(color: AppColors.textMuted)),
                if (provider.experienceYears != null)
                  Text(
                    '${provider.experienceYears} yrs exp',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          GradientButton(
            text: 'Select Provider',
            isLoading: isLoading,
            onPressed: onSelect,
          ),
        ],
      ),
    );
  }
}
