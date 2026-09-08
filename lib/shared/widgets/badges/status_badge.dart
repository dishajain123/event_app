import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum StatusTone { neutral, accent, success, warning, danger, info }

/// The one badge widget every status indicator in the app uses. Public API
/// is unchanged — [label] and [tone] are the exact same constructor
/// parameters, keyed off each feature's own real backend enum values
/// exactly as before. Visually it now renders a small tone-colored dot
/// alongside the label rather than a flat pill, reading a little more like
/// a live status indicator and a little less like a generic tag.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusTone tone;

  const StatusBadge(
      {super.key, required this.label, this.tone = StatusTone.neutral});

  (Color, Color) get _colors => switch (tone) {
        StatusTone.neutral => (
            const Color(0xFFF1F5F9),
            const Color(0xFF475569)
          ),
        StatusTone.accent => (AppColors.accentSoft, AppColors.accentStrong),
        StatusTone.success => (AppColors.successSoft, AppColors.success),
        StatusTone.warning => (AppColors.warningSoft, AppColors.warning),
        StatusTone.danger => (AppColors.dangerSoft, AppColors.danger),
        StatusTone.info => (AppColors.infoSoft, AppColors.info),
      };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: foreground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}