import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/discovery_refresh_provider.dart';
import '../../../core/network/dio_exception_mapper.dart';

final manageableAccountsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  ref.watch(discoveryRefreshProvider);
  final response =
      await ref.watch(apiClientProvider).get<List<dynamic>>('/users/accounts');
  return response.data!.cast<Map<String, dynamic>>();
});

class StaffAccountsScreen extends ConsumerStatefulWidget {
  const StaffAccountsScreen({super.key});
  @override
  ConsumerState<StaffAccountsScreen> createState() => _StaffAccountsState();
}

class _StaffAccountsState extends ConsumerState<StaffAccountsScreen> {
  String? _busy;
  String? _error;

  Future<void> _change(Map<String, dynamic> account) async {
    final active = account['is_active'] == true;
    final action = active ? 'Disable' : 'Reactivate';
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('$action ${account['name'] ?? 'this account'}?'),
              content: Text(active
                  ? 'This blocks login, console and mobile staff access, including existing sessions.'
                  : 'This restores access to the existing account and its assigned roles.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(action)),
              ],
            ));
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = account['id'] as String;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).patch('/users/${account['id']}/status',
          data: {'status': active ? 'DISABLED' : 'ACTIVE'});
      if (!mounted) return;
      ref.invalidate(manageableAccountsProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(active ? 'Account disabled' : 'Account reactivated')));
    } catch (error) {
      if (mounted) setState(() => _error = mapDioException(error).message);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(manageableAccountsProvider);
    return Scaffold(
        appBar: AppBar(title: const Text('Volunteer accounts')),
        body: Column(children: [
          if (_error != null)
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
          Expanded(
              child: accounts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(mapDioException(error).message),
              TextButton(
                  onPressed: () => ref.invalidate(manageableAccountsProvider),
                  child: const Text('Try again')),
            ])),
            data: (rows) {
              final manageable = rows
                  .where((row) => row['can_manage_status'] == true)
                  .toList();
              return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(manageableAccountsProvider);
                    await ref.read(manageableAccountsProvider.future);
                  },
                  child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (manageable.isEmpty)
                          const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                  'No volunteer accounts available in your permission scope.')),
                        for (final account in manageable)
                          ListTile(
                            title:
                                Text(account['name'] as String? ?? 'Volunteer'),
                            subtitle: Text(
                                '${account['email'] ?? account['mobile_number'] ?? ''}\n${account['is_active'] == true ? 'Active' : 'Disabled'}'),
                            trailing: TextButton(
                                onPressed: _busy != null
                                    ? null
                                    : () => _change(account),
                                child: Text(_busy == account['id']
                                    ? 'Saving…'
                                    : account['is_active'] == true
                                        ? 'Disable'
                                        : 'Reactivate')),
                          ),
                      ]));
            },
          )),
        ]));
  }
}
