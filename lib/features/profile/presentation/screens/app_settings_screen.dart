import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../notifications/application/notifications_providers.dart';

/// Provider watched and the `updatePreferences({field: next})` call per
/// toggle are unchanged from before — this was previously the second
/// bare-spinner screen in the app; now on the same
/// loading/error/card standard as everywhere else.
class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AppBackground(
        child: SafeArea(
          child: preferences.when(
            loading: () => const AppSkeleton.form(fieldCount: 6),
            error: (error, stackTrace) => AppErrorState(
              error: error is AppException
                  ? error
                  : UnknownException(error.toString()),
              onRetry: () => ref.invalidate(notificationPreferencesProvider),
            ),
            data: (value) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const Text('Notifications', style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      _PreferenceTile(
                          title: 'Event reminders',
                          value: value.eventReminders,
                          field: 'event_reminders',
                          ref: ref),
                      const Divider(height: 1),
                      _PreferenceTile(
                          title: 'Registration and payment updates',
                          value: value.registrationUpdates,
                          field: 'registration_updates',
                          ref: ref),
                      const Divider(height: 1),
                      _PreferenceTile(
                          title: 'Cancellation and refund updates',
                          value: value.cancellationRefundUpdates,
                          field: 'cancellation_refund_updates',
                          ref: ref),
                      const Divider(height: 1),
                      _PreferenceTile(
                          title: 'Event changes',
                          value: value.eventChanges,
                          field: 'event_changes',
                          ref: ref),
                      const Divider(height: 1),
                      _PreferenceTile(
                          title: 'Operational notifications',
                          value: value.operationalNotifications,
                          field: 'operational_notifications',
                          ref: ref),
                      const Divider(height: 1),
                      _PreferenceTile(
                          title: 'Marketing and promotions',
                          value: value.marketingNotifications,
                          field: 'marketing_notifications',
                          ref: ref,
                          isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text('About', style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                const AppCard(
                  child: Column(
                    children: [
                      _InfoRow(label: 'Version', value: '0.1.0'),
                      Divider(height: 1),
                      _InfoRow(
                        label: 'Environment',
                        value: String.fromEnvironment('ENVIRONMENT_NAME',
                            defaultValue: 'development'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final String title;
  final bool value;
  final String field;
  final WidgetRef ref;
  final bool isLast;

  const _PreferenceTile(
      {required this.title,
      required this.value,
      required this.field,
      required this.ref,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.body),
      value: value,
      activeThumbColor: AppColors.accent,
      onChanged: (next) async {
        try {
          await ref
              .read(notificationsRepositoryProvider)
              .updatePreferences({field: next});
          ref.invalidate(notificationPreferencesProvider);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not update preference.')));
          }
        }
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMuted),
            Text(value, style: AppTypography.bodyStrong)
          ],
        ),
      );
}