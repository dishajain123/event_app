import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { medium, large }

/// The one button widget every screen uses (Section 3.10, 5.4) — no screen
/// hand-rolls its own ElevatedButton styling. [loading] shows an inline
/// spinner in place of the label rather than disabling silently, so a slow
/// action always has visible feedback.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;
    final height = size == AppButtonSize.large ? 52.0 : 46.0;

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: loading
          ? const SizedBox(
              key: ValueKey('loading'),
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2.2, color: Colors.white),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label, style: AppTypography.button),
              ],
            ),
    );

    final button = _buildForVariant(context, isDisabled, height, child);

    return fullWidth
        ? SizedBox(width: double.infinity, height: height, child: button)
        : button;
  }

  Widget _buildForVariant(
      BuildContext context, bool isDisabled, double height, Widget child) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
            minimumSize: Size(0, height),
          ),
          child: child,
        );
      case AppButtonVariant.danger:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
            minimumSize: Size(0, height),
          ),
          child: child,
        );
      case AppButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(minimumSize: Size(0, height)),
          child: child,
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(minimumSize: Size(0, height)),
          child: child,
        );
    }
  }
}
