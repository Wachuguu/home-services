import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../widgets/provider_match_card.dart';

class ProviderMatchScreen extends ConsumerWidget {
  final String categoryId;
  const ProviderMatchScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: const GradientAppBar(title: 'Nearby Providers'),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return const ProviderMatchCard();
        },
      ),
    );
  }
}
