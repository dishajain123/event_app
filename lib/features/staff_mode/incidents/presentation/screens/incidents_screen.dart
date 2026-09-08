import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/incidents_providers.dart';
import '../../../assignments/application/staff_assignments_providers.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';

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
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Choose event')),
            for (final assignment in assignments)
              ListTile(
                leading: const Icon(Icons.event_outlined),
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
            icon: const Icon(Icons.add_alert_outlined))
      ]),
      body: incidents.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load incidents: $error')),
        data: (page) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(incidentsProvider(null)),
          child: page.items.isEmpty
              ? ListView(children: const [
                  SizedBox(height: 220),
                  Center(child: Text('No incidents reported.'))
                ])
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: page.items.length,
                  itemBuilder: (_, index) {
                    final item = page.items[index];
                    return Card(
                        child: ListTile(
                            title: Text(item.title),
                            subtitle:
                                Text('${item.category} · ${item.status.name}'),
                            trailing: StatusBadge(
                                label: item.severity.name,
                                tone: item.severity.name == 'critical'
                                    ? StatusTone.danger
                                    : item.severity.name == 'high'
                                        ? StatusTone.warning
                                        : StatusTone.neutral)));
                  },
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
      appBar: AppBar(title: const Text('Report incident')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AppTextField(
            controller: _category,
            label: 'Category',
            hint: 'Medical, safety, venue...'),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
            initialValue: _severity,
            decoration: const InputDecoration(labelText: 'Severity'),
            items: const ['low', 'medium', 'high', 'critical']
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _severity = v ?? 'medium')),
        const SizedBox(height: 16),
        AppTextField(controller: _title, label: 'Title'),
        const SizedBox(height: 16),
        AppTextField(
            controller: _description, label: 'Description', maxLines: 5),
        const SizedBox(height: 24),
        AppButton(
            label: 'Report incident',
            loading: _saving,
            fullWidth: true,
            onPressed: _saving ? null : _submit)
      ]));
}
