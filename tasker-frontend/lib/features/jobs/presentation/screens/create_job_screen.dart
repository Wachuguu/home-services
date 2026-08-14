import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../controllers/job_controller.dart';
import '../../../categories/presentation/controllers/category_controller.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const CreateJobScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final job = await ref.read(jobControllerProvider.notifier).createJob({
          'categoryId': widget.categoryId,
          'title': _titleController.text,
          'description': _descController.text,
          'latitude': -1.286389,
          'longitude': 36.817223,
          'address': 'Nairobi CBD',
          'estimatedCost': 1500,
        });
        if (mounted) {
          context.pushReplacement('/providers/nearby/${widget.categoryId}');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const GradientAppBar(title: 'Request Service'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'E.g., Fix leaking kitchen sink',
                prefixIcon: Icons.title,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Provide more details...',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description, color: AppColors.textMuted),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              // Map preview placeholder
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('Map location (Nairobi CBD)', style: TextStyle(color: AppColors.textMuted))),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: 'Find Providers',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
