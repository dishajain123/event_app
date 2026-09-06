import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../application/auth_state_provider.dart';
import '../../../../app/router/route_paths.dart';

class MobileNumberScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const MobileNumberScreen({super.key, this.returnTo});

  @override
  ConsumerState<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends ConsumerState<MobileNumberScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rawInput = _controller.text;
    final normalized = tryNormalizeMobileNumber(rawInput);
    if (normalized == null) {
      setState(() => _errorText = 'Enter a valid Indian mobile number.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      final resendSeconds =
          await ref.read(authStateProvider.notifier).requestOtp(normalized);
      if (!mounted) return;
      final otpPath = Uri(
        path: RoutePaths.otpVerify,
        queryParameters:
            widget.returnTo == null ? null : {'returnTo': widget.returnTo!},
      ).toString();
      context.push(otpPath, extra: {
        'mobileNumber': normalized,
        'resendSeconds': resendSeconds,
        'returnTo': widget.returnTo,
      });
    } on AppException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
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
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.event_available_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Welcome', style: AppTypography.display),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Enter your mobile number and we'll send you a verification code.",
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppTextField(
                  controller: _controller,
                  label: 'Mobile number',
                  hint: '98765 43210',
                  keyboardType: TextInputType.phone,
                  errorText: _errorText,
                  autofocus: true,
                  onEditingComplete: _submit,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1,
                      child: Text('+91', style: AppTypography.bodyStrong),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Send code',
                  onPressed: _submit,
                  loading: _submitting,
                  fullWidth: true,
                  size: AppButtonSize.large,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text(
                    'Only accounts you sign in to here are ever created — there is no separate sign-up.',
                    style: AppTypography.captionSubtle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
