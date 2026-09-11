import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A new, additive shared widget — wraps a screen's body in the soft
/// ambient gradient background used throughout the reference direction.
/// Purely decorative and purely additive: existing screens that don't opt
/// into this keep their current [Scaffold] background exactly as-is;
/// nothing is forced.
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
        child,
      ],
    );
  }
}