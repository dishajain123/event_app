import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// A new, additive shared widget — the "Section title ... View All" row
/// pattern (event schedule, ongoing initiatives, etc.) so it's built once
/// instead of re-implemented per screen. [onSeeAll] is optional; when null,
/// the trailing action is simply omitted rather than shown disabled.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String actionLabel;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.actionLabel = 'View All',
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow!, style: AppTypography.overline),
                const SizedBox(height: 2),
              ],
              Text(title, style: AppTypography.headline),
            ],
          ),
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.accentStrong),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: AppColors.accentStrong),
                ],
              ),
            ),
          ),
      ],
    );
  }
}