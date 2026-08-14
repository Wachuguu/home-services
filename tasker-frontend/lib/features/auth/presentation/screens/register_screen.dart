import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/gradient_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'CLIENT';
  bool _acceptTerms = false;

  void _register() {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.error),
        );
        return;
      }

      ref.read(authControllerProvider.notifier).register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next.value != null && previous?.value == null) {
        context.go(next.value!.role == 'CLIENT' ? '/client-home' : '/provider-home');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      title: 'CLIENT',
                      icon: Icons.person_outline,
                      isSelected: _selectedRole == 'CLIENT',
                      onTap: () => setState(() => _selectedRole = 'CLIENT'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RoleCard(
                      title: 'PROVIDER',
                      icon: Icons.work_outline,
                      isSelected: _selectedRole == 'PROVIDER',
                      onTap: () => setState(() => _selectedRole = 'PROVIDER'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AuthTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'John Doe',
                prefixIcon: Icons.badge_outlined,
                validator: (v) => Validators.validateRequired(v, 'Full Name'),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'john@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '254700000000',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'At least 8 characters',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _acceptTerms,
                onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                title: const Text('I accept the Terms and Conditions', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primaryBlue,
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Register',
                isLoading: isLoading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundElevated : AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlueLight : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? AppColors.primaryBlueLight : AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
