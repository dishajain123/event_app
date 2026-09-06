import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../events/application/events_providers.dart';
import '../../application/sponsorship_providers.dart';

class SponsorshipInquiryScreen extends ConsumerStatefulWidget {
  const SponsorshipInquiryScreen({super.key});

  @override
  ConsumerState<SponsorshipInquiryScreen> createState() =>
      _SponsorshipInquiryScreenState();
}

class _SponsorshipInquiryScreenState
    extends ConsumerState<SponsorshipInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _business = TextEditingController();
  final _offer = TextEditingController();
  final _message = TextEditingController();
  String? _categoryId;
  String? _packageId;
  final _eventIds = <String>{};
  bool _submitting = false;

  @override
  void dispose() {
    for (final controller in [
      _company,
      _contact,
      _phone,
      _email,
      _business,
      _offer,
      _message
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(sponsorshipRepositoryProvider).createInquiry(
            companyName: _company.text.trim(),
            contactPerson: _contact.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            businessDetails: _business.text.trim(),
            categoryId: _categoryId,
            packageId: _packageId,
            eventIds: _eventIds.toList(),
            offerDetails: _offer.text.trim(),
            message: _message.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(mySponsorshipInquiriesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inquiry submitted successfully.')));
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(sponsorshipCategoriesProvider).valueOrNull ?? [];
    final packages = ref.watch(sponsorshipPackagesProvider).valueOrNull ?? [];
    final events =
        ref.watch(eventsListProvider(noEventsFilter)).valueOrNull ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Sponsorship Inquiry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _field(_company, 'Company / person name'),
            _field(_contact, 'Contact person'),
            _field(_phone, 'Phone number', keyboardType: TextInputType.phone),
            _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration:
                  const InputDecoration(labelText: 'Sponsorship category'),
              items: [
                for (final item in categories)
                  DropdownMenuItem(value: item.id, child: Text(item.name))
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _packageId,
              decoration:
                  const InputDecoration(labelText: 'Interested package'),
              items: [
                for (final item in packages)
                  DropdownMenuItem(value: item.id, child: Text(item.name))
              ],
              onChanged: (value) => setState(() => _packageId = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Interested events (optional)'),
            for (final event in events)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(event.name),
                value: _eventIds.contains(event.id),
                onChanged: (selected) => setState(() {
                  if (selected == true)
                    _eventIds.add(event.id);
                  else
                    _eventIds.remove(event.id);
                }),
              ),
            _field(_business, 'Business details',
                maxLines: 3, requiredField: false),
            _field(_offer, 'What you can offer / expected sponsorship',
                maxLines: 3, requiredField: false),
            _field(_message, 'Message or requirements',
                maxLines: 4, requiredField: false),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Submitting…' : 'Submit inquiry')),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool requiredField = true,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label),
          validator: requiredField
              ? (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null
              : null,
        ),
      );
}
