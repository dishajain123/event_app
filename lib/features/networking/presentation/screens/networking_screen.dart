import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/application/auth_state_provider.dart';
import '../../application/networking_providers.dart';
import '../../data/models/networking.dart';

class NetworkingScreen extends ConsumerWidget {
  final String eventId;
  const NetworkingScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(networkingProfileProvider(eventId));
    final connections = ref.watch(networkingConnectionsProvider(eventId));
    final auth = ref.watch(authStateProvider);
    final currentUserId = auth is AuthAuthenticated ? auth.user.id : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Networking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _profileSwitch(context, ref, profile),
          const SizedBox(height: 16),
          const Text('Recommended participants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          NetworkingDiscoveryPanel(eventId: eventId),
          const SizedBox(height: 24),
          const Text('My connection requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _connections(context, ref, connections, currentUserId),
        ],
      ),
    );
  }

  Widget _profileSwitch(BuildContext context, WidgetRef ref,
          AsyncValue<NetworkingProfile> state) =>
      state.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Text('Networking unavailable: $error'),
        data: (profile) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Appear in participant discovery'),
              value: profile.visibility == 'visible',
              onChanged: (value) async {
                await ref.read(networkingRepositoryProvider).update(eventId, {
                  'visibility': value ? 'visible' : 'hidden',
                  'display_name': profile.displayName,
                  'organization': profile.organization,
                  'designation': profile.designation,
                  'interests': profile.interests,
                  'skills': profile.skills,
                  'bio': profile.bio,
                  'share_contact': false,
                });
                ref.invalidate(networkingProfileProvider(eventId));
                ref.invalidate(networkingParticipantsProvider(eventId));
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _editProfile(context, ref, profile),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit networking profile'),
              ),
            ),
          ],
        ),
      );

  Future<void> _editProfile(
      BuildContext context, WidgetRef ref, NetworkingProfile profile) async {
    final displayName = TextEditingController(text: profile.displayName ?? '');
    final organization =
        TextEditingController(text: profile.organization ?? '');
    final designation = TextEditingController(text: profile.designation ?? '');
    final bio = TextEditingController(text: profile.bio ?? '');
    final interests = TextEditingController(text: profile.interests.join(', '));
    final skills = TextEditingController(text: profile.skills.join(', '));
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit networking profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: displayName,
                  decoration: const InputDecoration(labelText: 'Display name')),
              TextField(
                  controller: organization,
                  decoration: const InputDecoration(labelText: 'Organization')),
              TextField(
                  controller: designation,
                  decoration: const InputDecoration(labelText: 'Designation')),
              TextField(
                  controller: bio,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Bio')),
              TextField(
                  controller: interests,
                  decoration: const InputDecoration(
                      labelText: 'Interests (comma separated)')),
              TextField(
                  controller: skills,
                  decoration: const InputDecoration(
                      labelText: 'Skills (comma separated)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, {
              'display_name': displayName.text.trim().isEmpty
                  ? null
                  : displayName.text.trim(),
              'organization': organization.text.trim().isEmpty
                  ? null
                  : organization.text.trim(),
              'designation': designation.text.trim().isEmpty
                  ? null
                  : designation.text.trim(),
              'bio': bio.text.trim().isEmpty ? null : bio.text.trim(),
              'interests': _splitValues(interests.text),
              'skills': _splitValues(skills.text),
              'visibility': profile.visibility,
              'share_contact': false,
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (values == null || !context.mounted) return;
    try {
      await ref.read(networkingRepositoryProvider).update(eventId, values);
      ref.invalidate(networkingProfileProvider(eventId));
      ref.invalidate(networkingParticipantsProvider(eventId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Networking profile updated')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update profile: $error')),
        );
      }
    }
  }

  List<String> _splitValues(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList();

  Widget _connections(
          BuildContext context,
          WidgetRef ref,
          AsyncValue<List<NetworkingConnection>> state,
          String? currentUserId) =>
      state.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Text('Unable to load connections: $error'),
        data: (items) => items.isEmpty
            ? const Text('No connection requests yet.')
            : Column(
                children: items
                    .map((connection) => ListTile(
                          title: Text(connection.status),
                          subtitle: Text(connection.intent),
                          trailing: connection.status == 'blocked'
                              ? IconButton(
                                  icon: const Icon(Icons.lock_open),
                                  onPressed: () async {
                                    final other = connection.participantLowId ==
                                            currentUserId
                                        ? connection.participantHighId
                                        : connection.participantLowId;
                                    await ref
                                        .read(networkingRepositoryProvider)
                                        .unblock(eventId, other);
                                    ref.invalidate(
                                        networkingConnectionsProvider(eventId));
                                    ref.invalidate(
                                        networkingParticipantsProvider(
                                            eventId));
                                  })
                              : connection.status == 'pending'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          if (connection.requestedBy ==
                                              currentUserId)
                                            IconButton(
                                                icon: const Icon(
                                                    Icons.cancel_outlined),
                                                onPressed: () async {
                                                  await ref
                                                      .read(
                                                          networkingRepositoryProvider)
                                                      .connectionStatus(
                                                          connection.id,
                                                          'cancelled');
                                                  ref.invalidate(
                                                      networkingConnectionsProvider(
                                                          eventId));
                                                })
                                          else ...[
                                            IconButton(
                                                icon: const Icon(Icons.check),
                                                onPressed: () async {
                                                  await ref
                                                      .read(
                                                          networkingRepositoryProvider)
                                                      .connectionStatus(
                                                          connection.id,
                                                          'accepted');
                                                  ref.invalidate(
                                                      networkingConnectionsProvider(
                                                          eventId));
                                                }),
                                            IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () async {
                                                  await ref
                                                      .read(
                                                          networkingRepositoryProvider)
                                                      .connectionStatus(
                                                          connection.id,
                                                          'rejected');
                                                  ref.invalidate(
                                                      networkingConnectionsProvider(
                                                          eventId));
                                                }),
                                          ],
                                        ])
                                  : null,
                        ))
                    .toList()),
      );
}

class NetworkingDiscoveryPanel extends StatefulWidget {
  final String eventId;
  const NetworkingDiscoveryPanel({super.key, required this.eventId});

  @override
  State<NetworkingDiscoveryPanel> createState() =>
      _NetworkingDiscoveryPanelState();
}

class _NetworkingDiscoveryPanelState extends State<NetworkingDiscoveryPanel> {
  final _search = TextEditingController();
  final _items = <NetworkingProfile>[];
  final _activities = <NetworkingActivity>[];
  int _page = 1;
  int _total = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _page = 1;
        _items.clear();
      }
    });
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final result = await container
          .read(networkingRepositoryProvider)
          .discover(widget.eventId, page: _page, search: _search.text.trim());
      if (reset) {
        final activities = await container
            .read(networkingRepositoryProvider)
            .activities(widget.eventId);
        _activities
          ..clear()
          ..addAll(activities.items);
      }
      if (!mounted) return;
      setState(() {
        _total = result.total;
        _items.addAll(result.items);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _search,
                onSubmitted: (_) => _load(reset: true),
                decoration: const InputDecoration(
                  labelText: 'Search participants',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            IconButton(
                onPressed: () => _load(reset: true),
                icon: const Icon(Icons.refresh)),
          ]),
          if (_loading && _items.isEmpty)
            const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator())),
          if (_error != null) Text('Unable to load participants: $_error'),
          if (!_loading && _error == null && _items.isEmpty)
            const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No opted-in participants yet.')),
          ..._items.map(_tile),
          if (_activities.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Event activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._activities.map((activity) => ListTile(
                  leading: Icon(activity.activityType == 'competition'
                      ? Icons.emoji_events_outlined
                      : Icons.schedule),
                  title: Text(activity.title),
                  subtitle:
                      Text('${activity.activityType} · ${activity.status}'),
                )),
          ],
          if (_items.length < _total)
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () {
                      _page += 1;
                      _load(reset: false);
                    },
              child: Text(_loading ? 'Loading...' : 'Load more'),
            ),
        ],
      );

  Widget _tile(NetworkingProfile profile) => Card(
        child: ListTile(
          title: Text(profile.displayName ?? 'Participant'),
          subtitle: Text(
              '${profile.organization ?? ''} ${profile.designation ?? ''}\n${profile.explanation.join(', ')}'),
          isThreeLine: true,
          trailing: Wrap(spacing: 4, children: [
            IconButton(
              tooltip: 'Connect',
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () async {
                try {
                  await ProviderScope.containerOf(context, listen: false)
                      .read(networkingRepositoryProvider)
                      .connect(widget.eventId, profile.userId);
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request sent')));
                } catch (error) {
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unable to connect: $error')));
                }
              },
            ),
            IconButton(
              tooltip: 'Dismiss',
              icon: const Icon(Icons.close),
              onPressed: () async {
                try {
                  await ProviderScope.containerOf(context, listen: false)
                      .read(networkingRepositoryProvider)
                      .dismiss(widget.eventId, profile.userId);
                  if (mounted)
                    setState(() => _items
                        .removeWhere((item) => item.userId == profile.userId));
                } catch (error) {
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unable to dismiss: $error')));
                }
              },
            ),
            IconButton(
              tooltip: 'Report',
              icon: const Icon(Icons.report_outlined),
              onPressed: () => _report(profile),
            ),
          ]),
        ),
      );

  Future<void> _report(NetworkingProfile profile) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report participant'),
        content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Reason')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Submit')),
        ],
      ),
    );
    if (!mounted || reason == null || reason.trim().isEmpty) return;
    try {
      await ProviderScope.containerOf(context, listen: false)
          .read(networkingRepositoryProvider)
          .report(widget.eventId, profile.userId, reason.trim());
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Report submitted')));
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Unable to report: $error')));
    }
  }
}
