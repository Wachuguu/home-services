import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../widgets/category_chip.dart';

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
      const Center(child: Text('Jobs Tab (Coming Soon)')),
      const Center(child: Text('Profile Tab (Coming Soon)')),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 1) context.push('/jobs');
          else if (i == 2) context.push('/profile');
          else setState(() => _currentIndex = i);
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
              loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
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
                  // Simplified card for home view
                  return GestureDetector(
                    onTap: () => context.push('/jobs/create/${categories[index].id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: Text(categories[index].name)),
                    ),
                  );
                },
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
