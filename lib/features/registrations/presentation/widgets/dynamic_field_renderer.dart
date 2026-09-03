import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../config_engine/data/models/configurable_field.dart';

/// Renders a form from a backend-defined [ConfigurableField] list — the
/// core piece of Phase 3 (Section 3.6, 5.4): one widget per KNOWN field
/// type (text, number, select, date, boolean), and a plain text fallback
/// for anything this app doesn't recognize yet, so a new field type the
/// Console's Configuration Builder adds is never silently dropped from the
/// form, even before this renderer has a dedicated widget for it.
///
/// Deliberately stateless and controlled by the parent screen — this
/// widget owns no state of its own beyond what's needed to edit a text
/// field locally; [answers] and [onFieldChanged] are the single source of
/// truth, so the parent (RegistrationFormScreen) can run the real
/// eligibility dry-run against the current answers at any time.
class DynamicFieldRenderer extends StatelessWidget {
  final List<ConfigurableField> fields;
  final Map<String, dynamic> answers;
  final void Function(String key, dynamic value) onFieldChanged;
  final Map<String, String>? fieldErrors;

  const DynamicFieldRenderer({
    super.key,
    required this.fields,
    required this.answers,
    required this.onFieldChanged,
    this.fieldErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in fields) ...[
          _FieldWidget(
            field: field,
            value: answers[field.key],
            error: fieldErrors?[field.key],
            onChanged: (value) => onFieldChanged(field.key, value),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

class _FieldWidget extends StatelessWidget {
  final ConfigurableField field;
  final dynamic value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const _FieldWidget({required this.field, required this.value, required this.error, required this.onChanged});

  String get _labelWithRequiredMark => field.required ? '${field.label} *' : field.label;

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case 'number':
        return AppTextField(
          label: _labelWithRequiredMark,
          hint: 'Enter a number',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: error,
          onChanged: (text) => onChanged(text.isEmpty ? null : int.tryParse(text)),
        );

      case 'select':
        return _SelectField(field: field, value: value as String?, error: error, onChanged: onChanged);

      case 'date':
        return _DateField(field: field, value: value as String?, error: error, onChanged: onChanged);

      case 'boolean':
        return _BooleanField(field: field, value: value as bool? ?? false, onChanged: onChanged);

      case 'text':
      default:
        // Unknown types fall back here deliberately (see class doc) —
        // never a dropped field, just a plain text capture until this
        // renderer gains a dedicated widget for that type.
        return AppTextField(
          label: _labelWithRequiredMark,
          errorText: error,
          onChanged: onChanged,
        );
    }
  }
}

class _SelectField extends StatelessWidget {
  final ConfigurableField field;
  final String? value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const _SelectField({required this.field, required this.value, required this.error, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = field.options ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.required ? '${field.label} *' : field.label, style: AppTypography.bodyStrong),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: [
            for (final option in options) DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(errorText: error, hintText: 'Select…'),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final ConfigurableField field;
  final String? value; // stored as YYYY-MM-DD
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const _DateField({required this.field, required this.value, required this.error, required this.onChanged});

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = value != null ? DateTime.tryParse(value!) ?? now : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      final iso =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      onChanged(iso);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.required ? '${field.label} *' : field.label, style: AppTypography.bodyStrong),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickDate(context),
          child: InputDecorator(
            decoration: InputDecoration(errorText: error, hintText: 'Select a date'),
            child: Text(value ?? 'Select a date', style: AppTypography.body),
          ),
        ),
      ],
    );
  }
}

class _BooleanField extends StatelessWidget {
  final ConfigurableField field;
  final bool value;
  final ValueChanged<dynamic> onChanged;

  const _BooleanField({required this.field, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(field.label, style: AppTypography.body)),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.accent),
      ],
    );
  }
}
