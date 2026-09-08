import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/app_button.dart';

/// Shown when a request succeeds with zero results. Public API is
/// unchanged — [icon], [title], [description], [actionLabel], [onAction]
/// are the same constructor parameters as before. Visually the icon now
/// sits in a soft gradient "blob" rather than a flat circle, matching the
/// rest of the refreshed shared-widget set.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
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
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentSoft,
                    AppColors.accentSoft.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Icon(icon, size: 30, color: AppColors.accentStrong),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title,
                style: AppTypography.title, textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(description!,
                  style: AppTypography.bodyMuted, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: AppButtonVariant.secondary),
            ],
          ],
        ),
      ),
    );
  }
}