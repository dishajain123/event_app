import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A new, additive shared widget — wraps a screen's body in the soft
/// ambient gradient background used throughout the reference direction,
/// with two faint decorative color blobs anchored top-right and
/// bottom-left. Purely decorative and purely additive: existing screens
/// that don't opt into this keep their current [Scaffold] background
/// exactly as-is; nothing is forced.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: _Blob(color: AppColors.accentViolet.withValues(alpha: 0.10)),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: _Blob(color: AppColors.accentMagenta.withValues(alpha: 0.08)),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  const _Blob({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}