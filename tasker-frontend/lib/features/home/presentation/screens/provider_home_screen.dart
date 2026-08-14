import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/stats_card.dart';

class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    final tabs = [
      _buildDashboardTab(user?.fullName ?? 'Provider'),
      const Center(child: Text('Jobs Tab (Coming Soon)')),
      const Center(child: Text('Earnings Tab (Coming Soon)')),
      const Center(child: Text('Profile Tab (Coming Soon)')),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 1) context.push('/jobs');
          else if (i == 3) context.push('/profile');
          else setState(() => _currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(String name) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Welcome back,\n$name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isOnline ? AppColors.success.withOpacity(0.2) : AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 12, color: _isOnline ? AppColors.success : AppColors.textMuted),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isOnline,
                      onChanged: (val) => setState(() => _isOnline = val),
                      activeColor: AppColors.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Row(
            children: [
              Expanded(child: StatsCard(title: 'Completed', value: '24', icon: Icons.check_circle_outline, color: AppColors.success)),
              SizedBox(width: 16),
              Expanded(child: StatsCard(title: 'Rating', value: '4.9', icon: Icons.star_outline, color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Incoming Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Placeholder for incoming requests
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Center(
              child: Text('No new requests right now.\nStay online to receive jobs!', 
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
