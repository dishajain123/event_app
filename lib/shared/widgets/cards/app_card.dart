import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// A new, additive shared widget (nothing existing references it yet) —
/// the one card container Phase 2 screens should reach for instead of
/// hand-rolling their own `Container` + `BoxDecoration`. Two looks:
/// [AppCard.elevated] (solid white, soft shadow — the default for content
/// cards like an event card or a registration row) and [AppCard.glass]
/// (translucent, for cards that sit directly on the ambient gradient
/// background, e.g. a hero header stat strip).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool _glass;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.radius = AppRadius.card,
  }) : _glass = false;

  const AppCard.glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.radius = AppRadius.card,
  }) : _glass = true;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: _glass
            ? Colors.white.withValues(alpha: 0.62)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: _glass
            ? Border.all(color: Colors.white.withValues(alpha: 0.6))
            : null,
        boxShadow: _glass
            ? []
            : [
                const BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}