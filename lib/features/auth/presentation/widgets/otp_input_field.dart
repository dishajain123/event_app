import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// A single, wide-letter-spaced digit field rather than a multi-box
/// per-digit widget — deliberately the simpler of the two common OTP UX
/// patterns. A per-box widget needs careful focus-node-chaining logic
/// (auto-advance on digit entry, backspace-to-previous-box) that's easy to
/// get subtly wrong; given this code can't be run against a real device in
/// this environment to catch that class of bug interactively, the simpler,
/// harder-to-get-wrong pattern is the right tradeoff for Phase 1. Revisit
/// once real-device testing is in the loop, if desired.
class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final int length;

  const OtpInputField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: length,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 12,
        color: AppColors.ink,
      ),
      decoration: const InputDecoration(counterText: '', hintText: '••••••'),
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
