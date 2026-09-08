import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Counts down from [initialSeconds] (the backend's real
/// resend_available_in_seconds) and calls [onResend] once the user taps
/// after it reaches zero. Public API and timer logic are unchanged; only
/// the two rendered states (counting vs. ready) got a small visual pass.
class ResendTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onResend;

  const ResendTimer(
      {super.key, required this.initialSeconds, required this.onResend});

  @override
  State<ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<ResendTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ResendTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSeconds != oldWidget.initialSeconds) {
      _remaining = widget.initialSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remaining <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remaining -= 1;
      });
      if (_remaining <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 15, color: AppColors.inkSubtle),
          const SizedBox(width: 6),
          Text('Resend code in ${_remaining}s', style: AppTypography.caption),
        ],
      );
    }
    return InkWell(
      onTap: widget.onResend,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh_rounded,
                size: 15, color: AppColors.accentStrong),
            const SizedBox(width: 6),
            Text(
              'Resend code',
              style: AppTypography.caption.copyWith(
                color: AppColors.accentStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}