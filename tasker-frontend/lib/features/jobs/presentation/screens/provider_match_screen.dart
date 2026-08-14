import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../../../auth/domain/models/user.dart';
import '../../data/datasources/job_remote_ds.dart';

// Provider: fetch nearby providers for a given category using device location
final nearbyProvidersProvider =
    FutureProvider.family<List<User>, String>((ref, categoryId) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Location services are disabled.');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied.');
  }

  final pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );

  return ref.read(jobRemoteDsProvider).getNearbyProviders(
        categoryId,
        pos.latitude,
        pos.longitude,
        10.0, // 10 km default
      );
});

class ProviderMatchScreen extends ConsumerWidget {
  final String categoryId;
  const ProviderMatchScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(nearbyProvidersProvider(categoryId));

    return AppScaffold(
      appBar: const GradientAppBar(title: 'Nearby Providers'),
      body: providersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(nearbyProvidersProvider(categoryId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (providers) => providers.isEmpty
            ? const Center(
                child: Text(
                  'No providers found nearby.\nTry increasing the search radius.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(nearbyProvidersProvider(categoryId).future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) =>
                      _ProviderCard(provider: providers[i], categoryId: categoryId),
                ),
              ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final User provider;
  final String categoryId;

  const _ProviderCard({required this.provider, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                radius: 28,
                backgroundColor: AppColors.backgroundElevated,
                child: Text(
                  provider.fullName.isNotEmpty
                      ? provider.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlueLight),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${(provider.rating ?? 0.0).toStringAsFixed(1)} (${provider.totalReviews ?? 0} reviews)',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Availability badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Available',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => context.push(
                    '/jobs/create/$categoryId?providerId=${provider.id}'),
                child: const Text('Select Provider',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
