import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Shown for every screen whose real implementation lands in a later
/// phase (Section 8) — exists so every route in the app resolves to
/// something real today, proving the navigation/shell/switch machinery
/// end-to-end before the feature behind it is built.
class ComingSoonPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String phaseNote;

  const ComingSoonPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.phaseNote,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: AppColors.accentStrong),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.headline, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(phaseNote, style: AppTypography.bodyMuted, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
