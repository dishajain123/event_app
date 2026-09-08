import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// A new, additive shared widget — a selectable pill chip for filter rows
/// (event category tabs, schedule day tabs, etc. — the tabbed "Schedule /
/// Sports / Business / Networking" row in the reference direction). Purely
/// presentational: [selected] and [onTap] are driven entirely by whatever
/// state the calling screen already holds (e.g. a Riverpod filter
/// provider), so adopting this widget never changes what data is shown,
/// only how the control looks.
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0x14000000),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 15,
                    color: selected ? Colors.white : AppColors.inkMuted),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: selected ? Colors.white : AppColors.inkMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}