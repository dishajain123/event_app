import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// The one text field widget every form uses. Public API is unchanged —
/// every named parameter is identical to before — so nothing that already
/// constructs an [AppTextField] needs to change. Internally it now tracks
/// focus to animate its own label color/weight and border glow, instead of
/// relying only on the global [InputDecorationTheme].
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.onChanged,
    this.onEditingComplete,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: AppTypography.bodyStrong.copyWith(
              color: hasError
                  ? AppColors.danger
                  : (_focused ? AppColors.accentStrong : AppColors.ink),
            ),
            child: Text(widget.label!),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.input),
            boxShadow: _focused && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onEditingComplete: widget.onEditingComplete,
            inputFormatters: widget.inputFormatters,
            textInputAction: widget.textInputAction,
            style: AppTypography.body,
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
