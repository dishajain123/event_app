import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Counts down from [initialSeconds] (the backend's real
/// resend_available_in_seconds — Section 8, Phase 1) and calls
/// [onResend] once the user taps after it reaches zero.
class ResendTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onResend;

  const ResendTimer({super.key, required this.initialSeconds, required this.onResend});

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
      return Text('Resend code in ${_remaining}s', style: AppTypography.caption);
    }
    return GestureDetector(
      onTap: widget.onResend,
      child: const Text(
        'Resend code',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.accentStrong,
        ),
      ),
    );
  }
}
