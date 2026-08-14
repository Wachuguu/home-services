import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    if (user == null) return const SizedBox();

    return AppScaffold(
      appBar: const GradientAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.heroGradient,
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.backgroundElevated,
                child: Icon(Icons.person, size: 50, color: AppColors.primaryBlueLight),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role,
                style: const TextStyle(color: AppColors.primaryBlueLight, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.primaryBlueLight),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: AppColors.primaryBlueLight),
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primaryBlue),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: AppColors.primaryBlueLight),
            title: const Text('Dark Mode'),
            trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primaryBlue),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
