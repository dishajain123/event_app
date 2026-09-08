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
                const Text('Welcome', style: AppTypography.display),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Sign in to continue. You can use your mobile OTP or email password.',
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Mobile + OTP')),
                    ButtonSegment(value: true, label: Text('Email + password')),
                  ],
                  selected: {_emailMode},
                  onSelectionChanged: (value) => setState(() { _emailMode = value.first; _errorText = null; }),
                ),
                if (_emailMode) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Log in')),
                      ButtonSegment(value: false, label: Text('Sign up')),
                    ],
                    selected: {_loginMode},
                    onSelectionChanged: (value) => setState(() => _loginMode = value.first),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
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
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _recoverPassword, child: const Text('Forgot password?'))),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: _emailMode ? (_loginMode ? 'Log in' : 'Create account') : 'Send code',
                  onPressed: _submit,
                  loading: _submitting,
                  fullWidth: true,
                  size: AppButtonSize.large,
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.lg),
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
