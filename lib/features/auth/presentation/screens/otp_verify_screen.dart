import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../application/auth_state_provider.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/resend_timer.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String mobileNumber;
  final int initialResendSeconds;
  final String? returnTo;

  const OtpVerifyScreen({
    super.key,
    required this.mobileNumber,
    required this.initialResendSeconds,
    this.returnTo,
  });

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  bool _submitting = false;
  bool _resending = false;
  String? _errorText;
  late int _resendSeconds;

  @override
  void initState() {
    super.initState();
    _resendSeconds = widget.initialResendSeconds;
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) return;

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      // Router redirect logic (app/router/app_router.dart) sends the user
      // to the correct shell once authStateProvider resolves to
      // Authenticated — this screen doesn't decide where to go next.
      await ref.read(authStateProvider.notifier).verifyOtpAndLogIn(
            mobileNumber: widget.mobileNumber,
            otp: otp,
          );
      if (mounted) context.go(widget.returnTo ?? RoutePaths.home);
    } on AppException catch (e) {
      setState(() {
        _errorText = e.message;
        _otpController.clear();
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final seconds = await ref
          .read(authStateProvider.notifier)
          .requestOtp(widget.mobileNumber);
      if (mounted) setState(() => _resendSeconds = seconds);
    } on AppException catch (e) {
      if (mounted) setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.6)),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Enter the code', style: AppTypography.display),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sent to ${formatMobileNumberForDisplay(widget.mobileNumber)}',
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.xxl),
                OtpInputField(
                  controller: _otpController,
                  onSubmitted: _verify,
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(_errorText!,
                      style:
                          AppTypography.body.copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: _resending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : ResendTimer(
                          key: ValueKey(_resendSeconds),
                          initialSeconds: _resendSeconds,
                          onResend: _resend,
                        ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Verify & continue',
                  onPressed: _verify,
                  loading: _submitting,
                  fullWidth: true,
                  size: AppButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
