import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../events/application/events_providers.dart';
import '../../application/sponsorship_providers.dart';

/// Form key, controllers, and [_submit]'s `createInquiry(...)` call are
/// unchanged from before — same validation, same arguments. [TextFormField]
/// is kept rather than swapped for [AppTextField] since the latter has no
/// [Form]/validator integration; only decoration and layout are refreshed.
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
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
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _field(_company, 'Company / person name'),
              _field(_contact, 'Contact person'),
              _field(_phone, 'Phone number', keyboardType: TextInputType.phone),
              _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
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
                initialValue: _packageId,
                decoration:
                    const InputDecoration(labelText: 'Interested package'),
                items: [
                  for (final item in packages)
                    DropdownMenuItem(value: item.id, child: Text(item.name))
                ],
                onChanged: (value) => setState(() => _packageId = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Interested events (optional)',
                  style: AppTypography.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              if (events.isEmpty)
                const Text('No events to select yet.',
                    style: AppTypography.captionSubtle)
              else
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      for (final event in events)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(event.name),
                          value: _eventIds.contains(event.id),
                          onChanged: (selected) => setState(() {
                            if (selected == true) {
                              _eventIds.add(event.id);
                            } else {
                              _eventIds.remove(event.id);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              _field(_business, 'Business details',
                  maxLines: 3, requiredField: false),
              _field(_offer, 'What you can offer / expected sponsorship',
                  maxLines: 3, requiredField: false),
              _field(_message, 'Message or requirements',
                  maxLines: 4, requiredField: false),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: _submitting ? 'Submitting…' : 'Submit inquiry',
                fullWidth: true,
                size: AppButtonSize.large,
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
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