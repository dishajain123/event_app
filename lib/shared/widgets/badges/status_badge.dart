import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum StatusTone { neutral, accent, success, warning, danger, info }

/// The one badge widget every status indicator in the app uses (Section
/// 3.10, 5.4) — colored from the same tone palette the web console's
/// badges use, so e.g. a "confirmed" registration reads as the same green
/// on both surfaces. Each feature (registrations, teams, tickets, from
/// Phase 3 onward) provides its own status-string → [StatusTone] mapping
/// keyed off the real backend enum values; this widget only renders
/// whatever tone and label it's given.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusTone tone;

  const StatusBadge({super.key, required this.label, this.tone = StatusTone.neutral});

  (Color, Color) get _colors => switch (tone) {
        StatusTone.neutral => (const Color(0xFFF1F5F9), const Color(0xFF475569)),
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
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
