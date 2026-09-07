import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../notifications/application/notifications_providers.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: preferences.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(error is AppException
                ? error.message
                : 'Unable to load preferences.'),
          ),
          data: (value) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text('Notifications', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              _PreferenceTile(
                  title: 'Event reminders',
                  value: value.eventReminders,
                  field: 'event_reminders',
                  ref: ref),
              _PreferenceTile(
                  title: 'Registration and payment updates',
                  value: value.registrationUpdates,
                  field: 'registration_updates',
                  ref: ref),
              _PreferenceTile(
                  title: 'Cancellation and refund updates',
                  value: value.cancellationRefundUpdates,
                  field: 'cancellation_refund_updates',
                  ref: ref),
              _PreferenceTile(
                  title: 'Event changes',
                  value: value.eventChanges,
                  field: 'event_changes',
                  ref: ref),
              _PreferenceTile(
                  title: 'Operational notifications',
                  value: value.operationalNotifications,
                  field: 'operational_notifications',
                  ref: ref),
              _PreferenceTile(
                  title: 'Marketing and promotions',
                  value: value.marketingNotifications,
                  field: 'marketing_notifications',
                  ref: ref),
              const SizedBox(height: AppSpacing.xl),
              Text('About', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              const _InfoRow(label: 'Version', value: '0.1.0'),
              _InfoRow(
                label: 'Environment',
                value: const String.fromEnvironment('ENVIRONMENT_NAME',
                    defaultValue: 'development'),
              ),
            ],
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

  const _PreferenceTile(
      {required this.title,
      required this.value,
      required this.field,
      required this.ref});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
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
