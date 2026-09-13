import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/discovery_refresh_provider.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/badges/status_badge.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/misc/app_avatar.dart';
import '../../../shared/widgets/scaffolds/app_background.dart';
import '../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../shared/widgets/states/app_empty_state.dart';
import '../../../shared/widgets/states/app_error_state.dart';
import '../../../shared/widgets/states/app_skeleton.dart';

final manageableAccountsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  ref.watch(discoveryRefreshProvider);
  final response =
      await ref.watch(apiClientProvider).get<List<dynamic>>('/users/accounts');
  return response.data!.cast<Map<String, dynamic>>();
});

/// Rebuilt on the same shared-widget standard as the rest of Staff Mode
/// (AppCard/AppTypography/StatusBadge/AppEmptyState/AppErrorState/
/// AppSkeleton/showConfirmActionSheet) — this screen was the one holdout
/// still using bare ListTile/AlertDialog/CircularProgressIndicator with no
/// design-system styling at all. Every API call, field name, and mutation
/// payload below is unchanged.
class StaffAccountsScreen extends ConsumerStatefulWidget {
  const StaffAccountsScreen({super.key});
  @override
  ConsumerState<StaffAccountsScreen> createState() => _StaffAccountsState();
}

class _StaffAccountsState extends ConsumerState<StaffAccountsScreen> {
  String? _busy;

  Future<void> _change(Map<String, dynamic> account) async {
    final active = account['is_active'] == true;
    final action = active ? 'Disable' : 'Reactivate';
    final name = account['name'] as String? ?? 'this account';

    final confirmed = await showConfirmActionSheet(
      context,
      title: '$action $name?',
      description: active
          ? 'This blocks login, console and mobile staff access, including existing sessions.'
          : 'This restores access to the existing account and its assigned roles.',
      confirmLabel: action,
      danger: active,
      onConfirm: (_) async {
        setState(() => _busy = account['id'] as String);
        try {
          await ref.read(apiClientProvider).patch(
              '/users/${account['id']}/status',
              data: {'status': active ? 'DISABLED' : 'ACTIVE'});
          if (!mounted) return;
          ref.invalidate(manageableAccountsProvider);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(active ? 'Account disabled' : 'Account reactivated')));
        } finally {
          if (mounted) setState(() => _busy = null);
        }
      },
    );
    if (!confirmed && mounted) setState(() => _busy = null);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(manageableAccountsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer accounts')),
      body: AppBackground(
        child: accounts.when(
          loading: () => const AppSkeleton.cardList(count: 5),
          error: (error, _) => AppErrorState(
            error: mapDioException(error),
            onRetry: () => ref.invalidate(manageableAccountsProvider),
          ),
          data: (rows) {
            final manageable =
                rows.where((row) => row['can_manage_status'] == true).toList();
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(manageableAccountsProvider);
                await ref.read(manageableAccountsProvider.future);
              },
              child: manageable.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 220),
                        AppEmptyState(
                          icon: Icons.groups_outlined,
                          title: 'No volunteer accounts',
                          description:
                              'No accounts are available in your permission scope.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: manageable.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final account = manageable[index];
                        final id = account['id'] as String;
                        final name = account['name'] as String? ?? 'Volunteer';
                        final contact = account['email'] as String? ??
                            account['mobile_number'] as String? ??
                            '';
                        final active = account['is_active'] == true;
                        final saving = _busy == id;

                        return AppCard(
                          child: Row(
                            children: [
                              AppAvatar(name: name, size: 44),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: AppTypography.bodyStrong),
                                    const SizedBox(height: 2),
                                    Text(contact,
                                        style: AppTypography.caption,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    StatusBadge(
                                      label: active ? 'Active' : 'Disabled',
                                      tone: active
                                          ? StatusTone.success
                                          : StatusTone.neutral,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              AppButton(
                                label: saving
                                    ? 'Saving…'
                                    : active
                                        ? 'Disable'
                                        : 'Reactivate',
                                variant: active
                                    ? AppButtonVariant.danger
                                    : AppButtonVariant.secondary,
                                loading: saving,
                                onPressed: _busy != null
                                    ? null
                                    : () => _change(account),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
