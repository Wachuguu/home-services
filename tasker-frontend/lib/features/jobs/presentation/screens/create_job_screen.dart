import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../controllers/job_controller.dart';

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
  final _addressController = TextEditingController();
  bool _isLoading = false;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
        });
      }
    } catch (_) {
      // Fallback: Ongata Rongai
      if (mounted) {
        setState(() {
          _lat = -1.3958;
          _lng = 36.7620;
        });
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final newJob = await ref.read(jobControllerProvider.notifier).createJob({
        'categoryId': int.tryParse(widget.categoryId) ?? widget.categoryId,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'latitude': _lat ?? -1.3958,
        'longitude': _lng ?? 36.7620,
        'address':
            _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : 'Current Location',
        'estimatedCost': 1500,
      });
      if (mounted) {
        context.pushReplacement(
          '/providers/nearby/${widget.categoryId}?jobId=${newJob.id}',
          extra: newJob.id,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
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
                    child:
                        Icon(Icons.description, color: AppColors.textMuted),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _addressController,
                label: 'Address (optional)',
                hint: 'E.g., Ongata Rongai, near Total',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 24),
              // Location indicator
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Center(
                  child: _lat != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.my_location,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('Detecting location...',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13)),
                          ],
                        ),
                ),
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
