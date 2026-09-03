import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Deliberately minimal — the backend has no notification-preferences
/// endpoint at all (confirmed directly against the live router; nothing
/// resembling it exists anywhere in the notifications module), so this
/// screen doesn't pretend to have one. A toggle that looks like it saves
/// a preference but silently does nothing would be worse than not
/// having the screen at all. This is app info only, until a real
/// preferences endpoint exists to build against.
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('About', style: AppTypography.title),
            const SizedBox(height: AppSpacing.md),
            const _InfoRow(label: 'Version', value: '0.1.0'),
            const _InfoRow(label: 'Environment', value: String.fromEnvironment('ENVIRONMENT_NAME', defaultValue: 'development')),
            const SizedBox(height: AppSpacing.xl),
            Text('Support', style: AppTypography.title),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Notification preferences and other account settings will be added here once the '
              "backend supports them — this screen intentionally doesn't show a toggle that "
              "wouldn't actually do anything yet.",
              style: AppTypography.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMuted),
          Text(value, style: AppTypography.bodyStrong),
        ],
      ),
    );
  }
}
