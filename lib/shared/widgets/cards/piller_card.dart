import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../misc/pressable.dart';

/// Home's pillar/category tile. Compact and left-aligned rather than a
/// big centered square — icon badge up top, title + a one-line taxonomy
/// preview below, a small affordance arrow in the corner. The gradient
/// carries a faint diagonal sheen for depth and a shadow tinted to the
/// pillar's own solid color, so four tiles read as distinct, designed
/// surfaces rather than four identical template blocks.
class PillarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int moreCount;
  final IconData icon;
  final Gradient gradient;
  final Color shadowTint;
  final VoidCallback? onTap;

  const PillarCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.moreCount = 0,
    required this.icon,
    required this.gradient,
    required this.shadowTint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleLine =
        moreCount > 0 ? '$subtitle +$moreCount more' : subtitle;

    return Pressable(
      onTap: onTap,
      pressedScale: 0.96,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: shadowTint.withValues(alpha: 0.32),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // A faint diagonal sheen for glass-like depth — not another
            // gradient hue, just a soft light pass over the existing one.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 17),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyStrong.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitleLine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionSubtle.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
