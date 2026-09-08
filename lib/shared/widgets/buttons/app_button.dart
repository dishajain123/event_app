import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { medium, large }

/// The one button widget every screen uses. Public API is unchanged —
/// [label], [onPressed], [variant], [size], [loading], [fullWidth], [icon]
/// are the exact same named parameters as before, so every existing call
/// site across the app compiles and behaves the same, just renders with a
/// premium gradient surface (primary), a soft press-scale animation, and a
/// halo shadow instead of a flat Material button. [loading] still shows an
/// inline spinner in place of the label rather than disabling silently.
class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.loading;

  void _setPressed(bool value) {
    if (_isDisabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.size == AppButtonSize.large ? 54.0 : 48.0;

    final labelChild = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: widget.loading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: widget.variant == AppButtonVariant.secondary ||
                        widget.variant == AppButtonVariant.ghost
                    ? AppColors.accent
                    : Colors.white,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  widget.label,
                  style: widget.size == AppButtonSize.large
                      ? AppTypography.buttonLarge
                      : AppTypography.button,
                ),
              ],
            ),
    );

    Widget button = _buildForVariant(height, labelChild);

    button = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: button,
    );

    if (!_isDisabled) {
      button = GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: button,
      );
    }

    return widget.fullWidth
        ? SizedBox(width: double.infinity, height: height, child: button)
        : SizedBox(height: height, child: button);
  }

  Widget _buildForVariant(double height, Widget child) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _GradientSurface(
          height: height,
          disabled: _isDisabled,
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.accent, AppColors.accentViolet],
          ),
          shadowColor: AppColors.accent,
          onTap: widget.onPressed,
          child: child,
        );
      case AppButtonVariant.danger:
        return _GradientSurface(
          height: height,
          disabled: _isDisabled,
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFEF4444), AppColors.danger],
          ),
          shadowColor: AppColors.danger,
          onTap: widget.onPressed,
          child: child,
        );
      case AppButtonVariant.secondary:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isDisabled ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(
                  color: _isDisabled
                      ? const Color(0x1F475569)
                      : const Color(0x33475569),
                ),
              ),
              child: DefaultTextStyle(
                style: AppTypography.button.copyWith(
                  color: _isDisabled ? AppColors.inkSubtle : AppColors.ink,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: _isDisabled ? AppColors.inkSubtle : AppColors.ink,
                    size: 18,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      case AppButtonVariant.ghost:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isDisabled ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: AppTypography.button.copyWith(
                  color: _isDisabled
                      ? AppColors.inkSubtle
                      : AppColors.accentStrong,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: _isDisabled
                        ? AppColors.inkSubtle
                        : AppColors.accentStrong,
                    size: 18,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
    }
  }
}

/// Shared gradient-filled surface used by the primary and danger variants:
/// a rounded gradient container with a soft tinted shadow, ripple, and a
/// disabled (desaturated) state.
class _GradientSurface extends StatelessWidget {
  final double height;
  final bool disabled;
  final Gradient gradient;
  final Color shadowColor;
  final VoidCallback? onTap;
  final Widget child;

  const _GradientSurface({
    required this.height,
    required this.disabled,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.button),
        gradient: disabled
            ? LinearGradient(colors: [
                shadowColor.withValues(alpha: 0.35),
                shadowColor.withValues(alpha: 0.35),
              ])
            : gradient,
        boxShadow: disabled
            ? const []
            : [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.button),
          splashColor: Colors.white.withValues(alpha: 0.14),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Center(
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white, size: 18),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}