import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Public API is unchanged — [controller], [onChanged], [onSubmitted],
/// [length] are the same parameters as before, and this is still backed
/// by a single [TextField] rather than N separately-focused boxes: a
/// per-box widget needs careful focus-node-chaining logic (auto-advance on
/// digit entry, backspace-to-previous-box) that's easy to get subtly
/// wrong, and this code can't be run against a real device in this
/// environment to catch that class of bug interactively. What changed is
/// purely visual — the single [TextField] is now rendered as transparent
/// and stacked on top of a row of digit "boxes" that read their content
/// from the same [controller], so it looks like segmented OTP boxes while
/// keeping the simpler, harder-to-get-wrong input model underneath.
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
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final digits = value.text;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(length, (index) {
                  final filled = index < digits.length;
                  final isCursor = index == digits.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 44,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: filled ? AppColors.accentSoft : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: Border.all(
                        color: isCursor
                            ? AppColors.accent
                            : (filled
                                ? Colors.transparent
                                : const Color(0x14000000)),
                        width: isCursor ? 1.6 : 1,
                      ),
                    ),
                    child: Text(
                      filled ? digits[index] : '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          // Transparent real input, sized to match, so taps anywhere in
          // the row focus it and the system keyboard drives entry exactly
          // as it did before.
          Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: length,
              showCursor: false,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted?.call(),
            ),
          ),
        ],
      ),
    );
  }
}