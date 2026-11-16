import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../../data/datasources/job_remote_ds.dart';
import '../../domain/models/provider_match.dart';
import '../controllers/job_controller.dart';
import '../widgets/provider_match_card.dart';

// Provider: fetch nearby providers for a given category using device location
final nearbyProvidersProvider =
    FutureProvider.family<List<ProviderMatch>, String>((ref, categoryId) async {
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

class ProviderMatchScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String? jobId;

  const ProviderMatchScreen({
    super.key,
    required this.categoryId,
    this.jobId,
  });

  @override
  ConsumerState<ProviderMatchScreen> createState() =>
      _ProviderMatchScreenState();
}

class _ProviderMatchScreenState extends ConsumerState<ProviderMatchScreen> {
  String? _matchingProviderId;

  Future<void> _selectProvider(String providerId) async {
    final jobId = widget.jobId;
    if (jobId == null || jobId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No job found to match with this provider.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _matchingProviderId = providerId);
    try {
      await ref.read(jobRemoteDsProvider).matchProvider(jobId, providerId);
      ref.invalidate(jobControllerProvider);
      if (mounted) {
        context.pushReplacement('/jobs/$jobId');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to match provider.';
      if (e.response?.data != null &&
          e.response?.data is Map &&
          e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to match provider: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _matchingProviderId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync =
        ref.watch(nearbyProvidersProvider(widget.categoryId));

    return AppScaffold(
      appBar: const GradientAppBar(title: 'Nearby Providers'),
      body: providersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                  onPressed: () => ref
                      .invalidate(nearbyProvidersProvider(widget.categoryId)),
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
                onRefresh: () => ref.refresh(
                    nearbyProvidersProvider(widget.categoryId).future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => ProviderMatchCard(
                    provider: providers[i],
                    isLoading: _matchingProviderId == providers[i].providerId,
                    onSelect: () => _selectProvider(providers[i].providerId),
                  ),
                ),
              ),
      ),
    );
  }
}
