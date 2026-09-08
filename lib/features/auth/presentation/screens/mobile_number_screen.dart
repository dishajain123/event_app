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

/// Login/sign-in entry point. All state fields, [_submit], and
/// [_recoverPassword] are unchanged from before — same mobile+OTP and
/// email+password flows, calling the exact same [authStateProvider]
/// methods with the exact same arguments. Only [build] (the visual layer)
/// is refreshed.
class MobileNumberScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const MobileNumberScreen({super.key, this.returnTo});

  @override
  ConsumerState<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends ConsumerState<MobileNumberScreen> {
  final _controller = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _emailMode = false;
  bool _loginMode = true;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rawInput = _controller.text.trim();
    if (_emailMode) {
      if (!rawInput.contains('@') || _passwordController.text.length < 8) {
        setState(() => _errorText = 'Enter a valid email and password (8+ characters).');
        return;
      }
      setState(() { _submitting = true; _errorText = null; });
      try {
        final auth = ref.read(authStateProvider.notifier);
        if (_loginMode) {
          await auth.loginEmail(email: rawInput, password: _passwordController.text);
          if (mounted) context.go(widget.returnTo ?? RoutePaths.home);
        } else {
          final seconds = await auth.signupEmail(email: rawInput, password: _passwordController.text);
          if (mounted) {
            context.push(Uri(path: RoutePaths.otpVerify, queryParameters: widget.returnTo == null ? null : {'returnTo': widget.returnTo!}).toString(), extra: {
              'email': rawInput, 'isEmail': true, 'resendSeconds': seconds, 'returnTo': widget.returnTo,
            });
          }
        }
      } on AppException catch (e) { if (mounted) setState(() => _errorText = e.message); }
      finally { if (mounted) setState(() => _submitting = false); }
      return;
    }
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

  Future<void> _recoverPassword() async {
    final emailController = TextEditingController(text: _controller.text.trim());
    final codeController = TextEditingController();
    final passwordController = TextEditingController();
    try {
      final email = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reset password'),
          content: TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address')),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(dialogContext, emailController.text.trim()), child: const Text('Send code'))],
        ),
      );
      if (email == null || !email.contains('@')) return;
      await ref.read(authStateProvider.notifier).requestPasswordReset(email);
      if (!mounted) return;
      final values = await showDialog<List<String>>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Enter reset code'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: codeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Email code')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(dialogContext, [codeController.text.trim(), passwordController.text]), child: const Text('Reset'))],
        ),
      );
      if (values == null || values[0].isEmpty || values[1].length < 8) return;
      await ref.read(authStateProvider.notifier).resetPassword(email: email, code: values[0], password: values[1]);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset. You can now sign in.')));
    } on AppException catch (e) {
      if (mounted) setState(() => _errorText = e.message);
    } finally {
      emailController.dispose(); codeController.dispose(); passwordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentViolet],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.32),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.event_available_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text('Welcome back', style: AppTypography.display),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Sign in to continue with your mobile OTP or email and password.',
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _ModeToggle(
                  emailMode: _emailMode,
                  onChanged: (value) =>
                      setState(() { _emailMode = value; _errorText = null; }),
                ),
                if (_emailMode) ...[
                  const SizedBox(height: AppSpacing.md),
                  _LoginSignupToggle(
                    loginMode: _loginMode,
                    onChanged: (value) => setState(() => _loginMode = value),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _controller,
                  label: _emailMode ? 'Email address' : 'Mobile number',
                  hint: _emailMode ? 'you@example.com' : '98765 43210',
                  keyboardType: _emailMode ? TextInputType.emailAddress : TextInputType.phone,
                  errorText: _errorText,
                  autofocus: true,
                  onEditingComplete: _submit,
                  prefixIcon: _emailMode ? null : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1,
                      child: Text('+91', style: AppTypography.bodyStrong),
                    ),
                  ),
                ),
                if (_emailMode) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'At least 8 characters',
                    obscureText: true,
                    errorText: null,
                  ),
                  if (_loginMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: _recoverPassword,
                          child: const Text('Forgot password?')),
                    ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: _emailMode ? (_loginMode ? 'Log in' : 'Create account') : 'Send code',
                  onPressed: _submit,
                  loading: _submitting,
                  fullWidth: true,
                  size: AppButtonSize.large,
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Only accounts you sign in to here are ever created — there is no separate sign-up.',
                  style: AppTypography.captionSubtle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Presentation-only replacement for the old [SegmentedButton]: a pill
/// track with an animated sliding indicator, driven by the exact same
/// boolean the screen already held ([_emailMode]).
class _ModeToggle extends StatelessWidget {
  final bool emailMode;
  final ValueChanged<bool> onChanged;
  const _ModeToggle({required this.emailMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _PillToggle(
      selectedRight: emailMode,
      leftLabel: 'Mobile + OTP',
      rightLabel: 'Email + password',
      onChanged: onChanged,
    );
  }
}

class _LoginSignupToggle extends StatelessWidget {
  final bool loginMode;
  final ValueChanged<bool> onChanged;
  const _LoginSignupToggle({required this.loginMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _PillToggle(
      selectedRight: !loginMode,
      leftLabel: 'Log in',
      rightLabel: 'Sign up',
      onChanged: (rightSelected) => onChanged(!rightSelected),
    );
  }
}

class _PillToggle extends StatelessWidget {
  final bool selectedRight;
  final String leftLabel;
  final String rightLabel;
  final ValueChanged<bool> onChanged;

  const _PillToggle({
    required this.selectedRight,
    required this.leftLabel,
    required this.rightLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(leftLabel, !selectedRight, () => onChanged(false))),
          Expanded(child: _segment(rightLabel, selectedRight, () => onChanged(true))),
        ],
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? AppColors.accentStrong : AppColors.inkMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}