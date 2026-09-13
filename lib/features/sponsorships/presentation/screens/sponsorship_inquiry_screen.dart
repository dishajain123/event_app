import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/chips/app_chip.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../event_categories/application/event_categories_providers.dart';
import '../../../events/application/events_providers.dart';
import '../../application/sponsorship_providers.dart';

/// [_submit]'s `createInquiry(...)` call, its arguments, and every backend
/// field name are unchanged from before. This is a full presentation
/// rebuild: [AppTextField] (manual validation instead of [Form], which
/// doesn't integrate with it) and [AppChip] replace bare [TextFormField]/
/// [DropdownButtonFormField], and the flat "every event in the platform as
/// one long checkbox column" is replaced by the same Main Category -> Sub
/// Category cascade the console uses, sourced from the same
/// [mainCategoriesProvider] / [eventsListProvider] the rest of the app
/// already reads from — narrowing to a manageable list instead of dumping
/// every event on screen at once.
class SponsorshipInquiryScreen extends ConsumerStatefulWidget {
  const SponsorshipInquiryScreen({super.key});

  @override
  ConsumerState<SponsorshipInquiryScreen> createState() =>
      _SponsorshipInquiryScreenState();
}

class _SponsorshipInquiryScreenState
    extends ConsumerState<SponsorshipInquiryScreen> {
  final _company = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _business = TextEditingController();
  final _offer = TextEditingController();
  final _message = TextEditingController();

  String? _categoryId;
  String? _packageId;
  String? _mainCategoryId;
  String? _subCategoryId;
  final _eventIds = <String>{};
  bool _submitting = false;
  final Map<String, String?> _errors = {};

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

  bool _validate() {
    _errors.clear();
    if (_company.text.trim().isEmpty) _errors['company'] = 'Required';
    if (_contact.text.trim().isEmpty) _errors['contact'] = 'Required';
    if (_phone.text.trim().isEmpty) _errors['phone'] = 'Required';
    if (_email.text.trim().isEmpty) _errors['email'] = 'Required';
    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
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
    final allPackages =
        ref.watch(sponsorshipPackagesProvider).valueOrNull ?? [];
    final packages = _categoryId == null
        ? allPackages
        : allPackages.where((p) => p.categoryId == _categoryId).toList();
    final mainCategories = ref.watch(mainCategoriesProvider).valueOrNull ?? [];
    final selectedMain = _mainCategoryId == null
        ? null
        : mainCategories.where((m) => m.id == _mainCategoryId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Sponsorship Inquiry')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const _Hero(),
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('Your details', icon: Icons.person_outline_rounded),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _company,
                    label: 'Company / person name',
                    hint: 'Acme Corp',
                    errorText: _errors['company'],
                    prefixIcon: const Icon(Icons.apartment_rounded, size: 20),
                    onChanged: (_) => _errors['company'] = null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _contact,
                    label: 'Contact person',
                    hint: 'Who should we reach out to?',
                    errorText: _errors['contact'],
                    prefixIcon:
                        const Icon(Icons.badge_outlined, size: 20),
                    onChanged: (_) => _errors['contact'] = null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _phone,
                    label: 'Phone number',
                    keyboardType: TextInputType.phone,
                    errorText: _errors['phone'],
                    prefixIcon: const Icon(Icons.call_outlined, size: 20),
                    onChanged: (_) => _errors['phone'] = null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _errors['email'],
                    prefixIcon:
                        const Icon(Icons.alternate_email_rounded, size: 20),
                    onChanged: (_) => _errors['email'] = null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('Sponsorship interest',
                icon: Icons.workspace_premium_outlined),
            const SizedBox(height: AppSpacing.md),
            if (categories.isEmpty)
              const _InlineHint('Sponsorship categories load shortly.')
            else ...[
              const Text('Category', style: AppTypography.caption),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final item in categories)
                    AppChip(
                      label: item.name,
                      selected: _categoryId == item.id,
                      onTap: () => setState(() {
                        _categoryId = _categoryId == item.id ? null : item.id;
                        if (_packageId != null &&
                            allPackages
                                    .firstWhereOrNull(
                                        (p) => p.id == _packageId)
                                    ?.categoryId !=
                                _categoryId) {
                          _packageId = null;
                        }
                      }),
                    ),
                ],
              ),
            ],
            if (packages.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Text('Package', style: AppTypography.caption),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final item in packages)
                    AppChip(
                      label: item.name,
                      selected: _packageId == item.id,
                      onTap: () => setState(
                          () => _packageId = _packageId == item.id ? null : item.id),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('Events you\'re interested in',
                icon: Icons.event_available_outlined),
            const SizedBox(height: AppSpacing.md),
            if (mainCategories.isEmpty)
              const _InlineHint('Event categories load shortly.')
            else ...[
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final main in mainCategories)
                    AppChip(
                      label: main.name,
                      selected: _mainCategoryId == main.id,
                      onTap: () => setState(() {
                        _mainCategoryId =
                            _mainCategoryId == main.id ? null : main.id;
                        _subCategoryId = null;
                      }),
                    ),
                ],
              ),
              if (selectedMain != null &&
                  selectedMain.activeSubCategoriesSorted.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final sub in selectedMain.activeSubCategoriesSorted)
                      AppChip(
                        label: sub.name,
                        selected: _subCategoryId == sub.id,
                        onTap: () => setState(() =>
                            _subCategoryId = _subCategoryId == sub.id ? null : sub.id),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (_mainCategoryId == null)
                const _InlineHint(
                    'Choose a category above to see its events, or leave it blank if you\'re not sure yet — you can still submit without picking any.')
              else
                _EventPicker(
                  mainCategoryId: _mainCategoryId,
                  subCategoryId: _subCategoryId,
                  selectedIds: _eventIds,
                  onToggle: (id, selected) => setState(() {
                    if (selected) {
                      _eventIds.add(id);
                    } else {
                      _eventIds.remove(id);
                    }
                  }),
                ),
              if (_eventIds.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('${_eventIds.length} event${_eventIds.length == 1 ? '' : 's'} selected',
                    style: AppTypography.captionSubtle),
              ],
            ],
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('Tell us more', icon: Icons.notes_rounded),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: _business,
                    label: 'Business details',
                    hint: 'What does your organization do?',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _offer,
                    label: 'What you can offer / expected sponsorship',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _message,
                    label: 'Message or requirements',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _submitting ? 'Submitting…' : 'Submit inquiry',
              fullWidth: true,
              size: AppButtonSize.large,
              loading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientStrong,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentStrong.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handshake_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Partner with GO-360°',
                    style: AppTypography.title
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  'Tell us about your brand and we\'ll match you with the right sponsorship opportunity.',
                  style: AppTypography.caption
                      .copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel(this.label, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentStrong),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: AppTypography.title)),
      ],
    );
  }
}

class _InlineHint extends StatelessWidget {
  final String text;
  const _InlineHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(text, style: AppTypography.captionSubtle),
    );
  }
}

/// Only ever rendered once a Main Category is chosen — replaces the old
/// "every event on the platform in one checkbox column" with the same
/// cascading category narrowing the console's event filters use, read
/// from the exact same [eventsListProvider] family the rest of the app
/// already relies on.
class _EventPicker extends ConsumerWidget {
  final String? mainCategoryId;
  final String? subCategoryId;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onToggle;

  const _EventPicker({
    required this.mainCategoryId,
    required this.subCategoryId,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query =
        (mainCategoryId: mainCategoryId, subCategoryId: subCategoryId);
    final eventsAsync = ref.watch(eventsListProvider(query));

    return eventsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const _InlineHint('Unable to load events right now.'),
      data: (events) {
        if (events.isEmpty) {
          return const AppEmptyState(
            icon: Icons.event_busy_outlined,
            title: 'No events in this category',
            description: 'Try another category, or leave it unselected.',
          );
        }
        return AppCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: events.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0x14000000)),
              itemBuilder: (context, index) {
                final event = events[index];
                final selected = selectedIds.contains(event.id);
                return InkWell(
                  onTap: () => onToggle(event.id, !selected),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? AppColors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.inkSubtle.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded,
                                  size: 15, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(event.name, style: AppTypography.body),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}
