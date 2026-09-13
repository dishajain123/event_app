import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/incidents_providers.dart';
import '../../../assignments/application/staff_assignments_providers.dart';
import '../../../../../core/network/dio_exception_mapper.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../../shared/widgets/states/app_error_state.dart';

/// [_openReport]'s event-picker logic and every provider/repository call
/// are unchanged from before — this was previously a bare-spinner /
/// `Text('Unable to load...: $error')` screen, now on the same
/// loading/error/card standard as the rest of the app.
class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  Future<void> _openReport(
      BuildContext context, List<dynamic> assignments) async {
    if (assignments.length == 1) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ReportIncidentScreen(
              eventId: assignments.first.eventId as String)));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Text('Choose event', style: AppTypography.title),
              ),
              for (final assignment in assignments)
                ListTile(
                  leading: const Icon(Icons.event_outlined,
                      color: AppColors.staffModeAccent),
                  title: Text(assignment.eventId as String),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ReportIncidentScreen(
                            eventId: assignment.eventId as String)));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref
            .watch(myStaffAssignmentsProvider)
            .valueOrNull
            ?.where((a) => a.status.name == 'active')
            .toList() ??
        [];
    final reportEventId = assignments.isNotEmpty;
    // Omit event_id so the backend returns every event in the caller's active scope.
    final incidents = ref.watch(incidentsProvider(null));
    return Scaffold(
      appBar: AppBar(title: const Text('Incidents'), actions: [
        IconButton(
            onPressed:
                !reportEventId ? null : () => _openReport(context, assignments),
            icon: const Icon(Icons.add_alert_outlined)),
        const SizedBox(width: AppSpacing.sm),
      ]),
      body: AppBackground(
        child: incidents.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorState(
            error: mapDioException(error),
            onRetry: () => ref.invalidate(incidentsProvider(null)),
          ),
          data: (page) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(incidentsProvider(null)),
            child: page.items.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 220),
                    AppEmptyState(
                      icon: Icons.warning_amber_rounded,
                      title: 'No incidents reported',
                      description: 'Reported incidents will show up here.',
                    ),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: page.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, index) {
                      final item = page.items[index];
                      return AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title,
                                      style: AppTypography.bodyStrong),
                                  const SizedBox(height: 2),
                                  Text('${item.category} · ${item.status.name}',
                                      style: AppTypography.caption),
                                ],
                              ),
                            ),
                            StatusBadge(
                                label: item.severity.name,
                                tone: item.severity.name == 'critical'
                                    ? StatusTone.danger
                                    : item.severity.name == 'high'
                                        ? StatusTone.warning
                                        : StatusTone.neutral),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class ReportIncidentScreen extends ConsumerStatefulWidget {
  final String eventId;
  const ReportIncidentScreen({super.key, required this.eventId});
  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _category = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _severity = 'medium';
  bool _saving = false;
  @override
  void dispose() {
    _category.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_category.text.trim().isEmpty ||
        _title.text.trim().isEmpty ||
        _description.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(incidentsRepositoryProvider).create(
          eventId: widget.eventId,
          category: _category.text.trim(),
          severity: _severity,
          title: _title.text.trim(),
          description: _description.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to report incident: $error')));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Report Incident')),
        body: AppBackground(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppTextField(
                  controller: _category,
                  label: 'Category',
                  hint: 'Medical, safety, venue...'),
              const SizedBox(height: AppSpacing.md),
              const Text('Severity', style: AppTypography.bodyStrong),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                  initialValue: _severity,
                  decoration: const InputDecoration(hintText: 'Select…'),
                  items: const ['low', 'medium', 'high', 'critical']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _severity = v ?? 'medium')),
              const SizedBox(height: AppSpacing.md),
              AppTextField(controller: _title, label: 'Title'),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                  controller: _description, label: 'Description', maxLines: 5),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: 'Report incident',
                  loading: _saving,
                  fullWidth: true,
                  size: AppButtonSize.large,
                  onPressed: _saving ? null : _submit)
            ],
          ),
        ),
      );
}