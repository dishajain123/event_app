import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../config_engine/application/config_engine_providers.dart';
import '../../../config_engine/data/models/configurable_field.dart';
import '../../../guardians/application/guardians_providers.dart';
import '../../application/registrations_providers.dart';
import '../../data/models/registration.dart';
import '../../data/models/registration_status.dart';
import '../widgets/dynamic_field_renderer.dart';

class RegistrationFormScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String participationType;

  const RegistrationFormScreen({super.key, required this.eventId, required this.participationType});

  @override
  ConsumerState<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends ConsumerState<RegistrationFormScreen> {
  final Map<String, dynamic> _answers = {};
  final Set<String> _confirmedDocuments = {};
  String? _dateOfBirthIso;
  String? _childId;
  final _participantNameController = TextEditingController();
  ValidationResult? _lastValidation;
  bool _validating = false;

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthIso =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void dispose() {
    _participantNameController.dispose();
    super.dispose();
  }

  Future<void> _checkEligibility() async {
    setState(() => _validating = true);
    try {
      final repository = ref.read(configEngineRepositoryProvider);
      final result = await repository.validateRegistration(
        eventId: widget.eventId,
        participationType: widget.participationType,
        dateOfBirthIso: _dateOfBirthIso,
        documentsProvided: _confirmedDocuments.toList(),
        answers: _answers,
      );
      if (mounted) setState(() => _lastValidation = result);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  Future<void> _submit() async {
    await showConfirmActionSheet(
      context,
      title: 'Submit this registration?',
      description: "You'll be able to track its status from My Registrations afterward.",
      confirmLabel: 'Submit',
      onConfirm: (reason) async {
        final repository = ref.read(registrationsRepositoryProvider);
        final registration = await repository.createRegistration(
          eventId: widget.eventId,
          participationType: widget.participationType,
          dateOfBirthIso: _dateOfBirthIso,
          childId: _childId,
          documentsProvided: _confirmedDocuments.toList(),
          answers: _answers,
          participants: _participantNameController.text.trim().isEmpty
              ? const []
              : [
                  RegistrationParticipantInput(
                    fullName: _participantNameController.text.trim(),
                    dateOfBirthIso: _dateOfBirthIso,
                  ),
                ],
        );
        ref.invalidate(myRegistrationsProvider);
        if (mounted) {
          // The sheet pops itself on a successful onConfirm (see
          // ConfirmActionSheetContentState._handleConfirm) — popping here
          // too would be a double-pop. context.go()/push() below replace
          // or extend the stack regardless, so it's safe to navigate
          // immediately after.
          if (registration.status == RegistrationStatus.pendingPayment) {
            context.go(RoutePaths.paymentCheckoutPath(registration.id));
          } else {
            context.go(RoutePaths.myRegistrations);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registration ${registration.status.label.toLowerCase()}.')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldSchemaAsync = ref.watch(
      eventFieldSchemaProvider((eventId: widget.eventId, participationType: widget.participationType)),
    );
    final configAsync = ref.watch(eventConfigurationProvider(widget.eventId));
    final childrenAsync = ref.watch(myChildrenProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Register — ${widget.participationType}')),
      body: SafeArea(
        child: fieldSchemaAsync.when(
          loading: () => const AppSkeleton.form(),
          error: (error, stackTrace) => AppErrorState(
            error: error is AppException ? error : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(
              eventFieldSchemaProvider((eventId: widget.eventId, participationType: widget.participationType)),
            ),
          ),
          data: (schema) {
            final fields = schema?.fields ?? const <ConfigurableField>[];
            final config = configAsync.valueOrNull;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                childrenAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (children) => children.isEmpty
                      ? const SizedBox.shrink()
                      : DropdownButtonFormField<String>(
                          value: _childId ?? '',
                          decoration: const InputDecoration(labelText: 'Registering for', hintText: 'Myself'),
                          items: [
                            const DropdownMenuItem<String>(value: '', child: Text('Myself')),
                            ...children.map(
                              (child) => DropdownMenuItem<String>(
                                value: child.id,
                                child: Text(child.fullName),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            final child = value == null || value.isEmpty
                                ? null
                                : children.firstWhere((candidate) => candidate.id == value);
                            setState(() {
                              _childId = value == null || value.isEmpty ? null : value;
                              _dateOfBirthIso = child?.dateOfBirth.toIso8601String().split('T').first;
                            });
                          },
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _participantNameController,
                  label: 'Another participant (optional)',
                  hint: 'Leave blank to register yourself',
                ),
                const SizedBox(height: AppSpacing.md),
                if (config != null && config.hasAgeRule) _DateOfBirthField(
                  value: _dateOfBirthIso,
                  onTap: _pickDateOfBirth,
                ),
                if (config != null && config.hasAgeRule) const SizedBox(height: AppSpacing.lg),

                if (config != null && config.requiredDocuments.isNotEmpty) ...[
                  Text('Required documents', style: AppTypography.bodyStrong),
                  const SizedBox(height: AppSpacing.sm),
                  for (final doc in config.requiredDocuments)
                    CheckboxListTile(
                      value: _confirmedDocuments.contains(doc),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _confirmedDocuments.add(doc);
                          } else {
                            _confirmedDocuments.remove(doc);
                          }
                        });
                      },
                      title: Text(doc),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                if (fields.isNotEmpty)
                  DynamicFieldRenderer(
                    fields: fields,
                    answers: _answers,
                    onFieldChanged: (key, value) => setState(() => _answers[key] = value),
                  ),

                const SizedBox(height: AppSpacing.md),

                if (_lastValidation != null) _ValidationBanner(result: _lastValidation!),
                const SizedBox(height: AppSpacing.lg),

                AppButton(
                  label: 'Check eligibility',
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  loading: _validating,
                  onPressed: _checkEligibility,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Submit registration',
                  fullWidth: true,
                  size: AppButtonSize.large,
                  onPressed: _submit,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;
  const _DateOfBirthField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date of birth', style: AppTypography.bodyStrong),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: const InputDecoration(hintText: 'Select your date of birth'),
            child: Text(value ?? 'Select your date of birth', style: AppTypography.body),
          ),
        ),
      ],
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  final ValidationResult result;
  const _ValidationBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final isEligible = result.isEligible;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isEligible ? AppColors.successSoft : AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isEligible ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isEligible ? AppColors.success : AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isEligible ? 'You meet the requirements for this event.' : result.combinedMessage,
              style: AppTypography.body.copyWith(color: isEligible ? AppColors.success : AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
