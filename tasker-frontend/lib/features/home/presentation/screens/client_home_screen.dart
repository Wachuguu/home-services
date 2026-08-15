import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../widgets/category_chip.dart';
import '../../../categories/presentation/widgets/category_card.dart';
import '../../../jobs/presentation/screens/job_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../shared/widgets/shimmer_loading_widget.dart';

import '../../../../shared/widgets/dynamic_background.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final categoriesAsync = ref.watch(categoryControllerProvider);

    final tabs = [
      _buildHomeTab(user?.fullName ?? 'User', categoriesAsync, context),
      const JobListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DynamicBackground(
        isHome: true,
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(String name, AsyncValue categoriesAsync, BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoryControllerProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.backgroundElevated,
                  child: Text(name[0], style: const TextStyle(color: AppColors.primaryBlueLight)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $name 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: AppColors.primaryBlueLight),
                        SizedBox(width: 4),
                        Text('Current Location', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('What do you need help with?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length.clamp(0, 5),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => CategoryChip(
                    category: categories[index],
                    onTap: () => context.push('/jobs/create/${categories[index].id}'),
                  ),
                ),
              ),
              loading: () => SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => const ShimmerLoadingWidget(width: 100, height: 50, borderRadius: 25),
                ),
              ),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/categories'),
                  child: const Text('See All', style: TextStyle(color: AppColors.primaryBlueLight)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // We would map Grid view here
            categoriesAsync.when(
              data: (categories) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categories.length.clamp(0, 4),
                itemBuilder: (context, index) {
                  return CategoryCard(category: categories[index]);
                },
              ),
              loading: () => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return const ShimmerLoadingWidget(width: double.infinity, height: double.infinity, borderRadius: 16);
                },
              ),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
