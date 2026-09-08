import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../application/guardians_providers.dart';

/// [_pickDate] and [_submit] are unchanged — same `createChild` repository
/// call with the same arguments.
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _nameController = TextEditingController();
  String? _dateOfBirthIso;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 8),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthIso =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _dateOfBirthIso == null) {
      setState(() => _error = 'Enter a name and date of birth.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repository = ref.read(guardiansRepositoryProvider);
      await repository.createChild(
          fullName: _nameController.text.trim(),
          dateOfBirthIso: _dateOfBirthIso!);
      ref.invalidate(myChildrenProvider);
      if (mounted) context.pop();
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppTextField(
                  controller: _nameController,
                  label: "Child's full name",
                  autofocus: true),
              const SizedBox(height: AppSpacing.lg),
              const Text('Date of birth', style: AppTypography.bodyStrong),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'Select date of birth',
                    suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                  ),
                  child: Text(_dateOfBirthIso ?? 'Select date of birth',
                      style: AppTypography.body),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(_error!,
                      style: AppTypography.body
                          .copyWith(color: AppColors.danger)),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: 'Add child',
                  fullWidth: true,
                  size: AppButtonSize.large,
                  loading: _submitting,
                  onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}