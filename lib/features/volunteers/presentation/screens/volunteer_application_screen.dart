import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/volunteer_providers.dart';
import '../../data/models/volunteer_application.dart';

class VolunteerApplicationScreen extends ConsumerStatefulWidget {
  final String eventId;
  const VolunteerApplicationScreen({super.key, required this.eventId});

  @override
  ConsumerState<VolunteerApplicationScreen> createState() =>
      _VolunteerApplicationScreenState();
}

class _VolunteerApplicationScreenState
    extends ConsumerState<VolunteerApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _skills = TextEditingController();
  final _availability = TextEditingController();
  final _responsibility = TextEditingController();
  final _message = TextEditingController();
  VolunteerApplicationType _applicationType =
      VolunteerApplicationType.volunteer;
  bool _submitting = false;

  @override
  void dispose() {
    for (final item in [
      _name,
      _phone,
      _email,
      _skills,
      _availability,
      _responsibility,
      _message
    ]) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(volunteerRepositoryProvider).create({
        'eventId': widget.eventId,
        'applicationType': _applicationType,
        'fullName': _name.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'skillsExperience': _skills.text.trim(),
        'availability': _availability.text.trim(),
        'preferredResponsibility': _responsibility.text.trim(),
        'message': _message.text.trim(),
      });
      if (!mounted) return;
      ref.invalidate(myVolunteerApplicationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Volunteer application submitted.')));
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Apply as Volunteer')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              DropdownButtonFormField<VolunteerApplicationType>(
                initialValue: _applicationType,
                decoration: const InputDecoration(labelText: 'Apply as'),
                items: const [
                  DropdownMenuItem(
                      value: VolunteerApplicationType.volunteer,
                      child: Text('Volunteer')),
                  DropdownMenuItem(
                      value: VolunteerApplicationType.eventManager,
                      child: Text('Event Manager')),
                ],
                onChanged: (value) => setState(() => _applicationType =
                    value ?? VolunteerApplicationType.volunteer),
              ),
              const SizedBox(height: AppSpacing.md),
              _field(_name, 'Name'),
              _field(_phone, 'Phone number'),
              _field(_email, 'Email', requiredField: false),
              _field(_skills, 'Skills / experience',
                  maxLines: 3, requiredField: false),
              _field(_availability, 'Availability',
                  maxLines: 2, requiredField: false),
              _field(_responsibility, 'Preferred responsibility',
                  requiredField: false),
              _field(_message, 'Message / notes',
                  maxLines: 3, requiredField: false),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child:
                      Text(_submitting ? 'Submitting…' : 'Submit application')),
            ],
          ),
        ),
      );

  Widget _field(TextEditingController controller, String label,
          {int maxLines = 1, bool requiredField = true}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label),
          validator: requiredField
              ? (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null
              : null,
        ),
      );
}
