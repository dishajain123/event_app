import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/password_reset_dialog.dart';
import '../../../../app/router/route_paths.dart';

/// Mobile OTP and email sign-in, with an independently owned reset dialog.
/// State fields and the request/validation logic in [_submit] are
/// unchanged from before — same [authStateProvider] calls, same
/// normalization via [tryNormalizeMobileNumber], same navigation
/// contracts. Everything below is a from-scratch visual composition: a
/// sliding Mobile/Email switch, a live-formatted phone field, inline
/// validity gating, and a crossfade between the two forms.
class MobileNumberScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const MobileNumberScreen({super.key, this.returnTo});

  @override
  ConsumerState<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends ConsumerState<MobileNumberScreen> {
  final _controller = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _submitting = false;
  bool _recovering = false;
  bool _emailMode = false;
  bool _loginMode = true;
  bool _obscurePassword = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    // Only used to keep the submit button's enabled state live — no
    // validation/business logic lives here, that's still entirely in
    // [_submit], unchanged.
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _setMode(bool emailMode) {
    if (_emailMode == emailMode) return;
    setState(() {
      _emailMode = emailMode;
      _errorText = null;
      _controller.clear();
      _passwordController.clear();
    });
  }

  bool get _canSubmit {
    if (_emailMode) {
      final email = _controller.text.trim();
      return email.contains('@') && _passwordController.text.length >= 8;
    }
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10;
  }

  Future<void> _submit() async {
    final rawInput = _controller.text.trim();
    if (_emailMode) {
      if (!rawInput.contains('@') || _passwordController.text.length < 8) {
        setState(() =>
            _errorText = 'Enter a valid email and password (8+ characters).');
        return;
      }
      setState(() {
        _submitting = true;
        _errorText = null;
      });
      try {
        final auth = ref.read(authStateProvider.notifier);
        if (_loginMode) {
          await auth.loginEmail(
              email: rawInput, password: _passwordController.text);
          if (mounted) context.go(widget.returnTo ?? RoutePaths.home);
        } else {
          final seconds = await auth.signupEmail(
              email: rawInput, password: _passwordController.text);
          if (mounted) {
            context.push(
                Uri(
                        path: RoutePaths.otpVerify,
                        queryParameters: widget.returnTo == null
                            ? null
                            : {'returnTo': widget.returnTo!})
                    .toString(),
                extra: {
                  'email': rawInput,
                  'isEmail': true,
                  'resendSeconds': seconds,
                  'returnTo': widget.returnTo,
                });
          }
        }
      } on AppException catch (e) {
        if (mounted) setState(() => _errorText = e.message);
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
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
    if (_recovering) return;
    FocusScope.of(context).unfocus();
    setState(() => _recovering = true);
    try {
      final reset = await showDialog<bool>(
        context: context,
        builder: (_) =>
            PasswordResetDialog(initialEmail: _controller.text.trim()),
      );
      if (reset == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset. You can now sign in.')),
        );
      }
    } finally {
      if (mounted) setState(() => _recovering = false);
    }
  }

  String get _submitLabel {
    if (!_emailMode) return 'Send OTP';
    return _loginMode ? 'Sign in' : 'Create account';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradientStrong,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentStrong.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.hub_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Welcome to GO-360°', style: AppTypography.display),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to register for events and manage your participation.',
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.xl),
                _ModeSwitch(emailMode: _emailMode, onChanged: _setMode),
                const SizedBox(height: AppSpacing.xl),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: Offset(
                          child.key == const ValueKey('mobile-form')
                              ? -0.04
                              : 0.04,
                          0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: _emailMode
                      ? _EmailForm(
                          key: const ValueKey('email-form'),
                          emailController: _controller,
                          passwordController: _passwordController,
                          passwordFocusNode: _passwordFocusNode,
                          obscurePassword: _obscurePassword,
                          onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          errorText: _errorText,
                          loginMode: _loginMode,
                          onToggleLoginMode: () => setState(() {
                            _loginMode = !_loginMode;
                            _errorText = null;
                          }),
                          recovering: _recovering,
                          onForgotPassword: _recoverPassword,
                          onSubmit: _submit,
                        )
                      : _MobileForm(
                          key: const ValueKey('mobile-form'),
                          controller: _controller,
                          errorText: _errorText,
                          onSubmit: _submit,
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: _submitLabel,
                  onPressed: (_submitting || !_canSubmit) ? null : _submit,
                  loading: _submitting,
                  fullWidth: true,
                  size: AppButtonSize.large,
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(RoutePaths.events),
                    child: const Text('Continue browsing events'),
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

/// The outer Mobile/Email switch — a track with a sliding white capsule
/// (not a per-segment recolor) so choosing a method reads as one fluid
/// motion rather than an instant swap.
class _ModeSwitch extends StatelessWidget {
  final bool emailMode;
  final ValueChanged<bool> onChanged;
  const _ModeSwitch({required this.emailMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: emailMode ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.chip - 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _segment(
                  icon: Icons.smartphone_rounded,
                  label: 'Mobile',
                  selected: !emailMode,
                  onTap: () => onChanged(false),
                ),
              ),
              Expanded(
                child: _segment(
                  icon: Icons.alternate_email_rounded,
                  label: 'Email',
                  selected: emailMode,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected ? AppColors.accentStrong : AppColors.inkMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.expand(
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 7),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Live-formats digits into "98765 43210" as the user types. Purely
/// cosmetic: [tryNormalizeMobileNumber] already strips non-digits, so the
/// space this inserts is never sent anywhere.
class _IndianMobileFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 5) buffer.write(' ');
      buffer.write(limited[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _MobileForm extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onSubmit;

  const _MobileForm({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: controller,
          label: 'Mobile number',
          hint: '98765 43210',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          errorText: errorText,
          autofocus: true,
          onEditingComplete: onSubmit,
          inputFormatters: [_IndianMobileFormatter()],
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('+91', style: AppTypography.bodyStrong),
                SizedBox(width: 10),
                _VerticalDivider(),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'We’ll text a one-time code to verify it’s you.',
          style: AppTypography.captionSubtle,
        ),
      ],
    );
  }
}

class _EmailForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final String? errorText;
  final bool loginMode;
  final VoidCallback onToggleLoginMode;
  final bool recovering;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  const _EmailForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.errorText,
    required this.loginMode,
    required this.onToggleLoginMode,
    required this.recovering,
    required this.onForgotPassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: emailController,
          label: 'Email address',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofocus: true,
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(passwordFocusNode),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.mail_outline_rounded,
                size: 19, color: AppColors.inkSubtle),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          label: 'Password',
          hint: 'At least 8 characters',
          obscureText: obscurePassword,
          errorText: errorText,
          textInputAction: TextInputAction.done,
          onEditingComplete: onSubmit,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.lock_outline_rounded,
                size: 19, color: AppColors.inkSubtle),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
              color: AppColors.inkSubtle,
            ),
            splashRadius: 18,
            onPressed: onToggleObscure,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InlineLinkRow(
              staticText: loginMode ? 'New here?' : 'Already have an account?',
              actionText: loginMode ? 'Create account' : 'Sign in',
              onTap: onToggleLoginMode,
            ),
            if (loginMode)
              TextButton(
                onPressed: recovering ? null : onForgotPassword,
                style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
                child: const Text('Forgot password?'),
              ),
          ],
        ),
      ],
    );
  }
}

class _InlineLinkRow extends StatelessWidget {
  final String staticText;
  final String actionText;
  final VoidCallback onTap;
  const _InlineLinkRow(
      {required this.staticText,
      required this.actionText,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 4),
        child: RichText(
          text: TextSpan(
            style: AppTypography.captionSubtle,
            children: [
              TextSpan(text: '$staticText '),
              TextSpan(
                text: actionText,
                style: const TextStyle(
                    color: AppColors.accentStrong, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 20,
        color: AppColors.inkSubtle.withValues(alpha: 0.28));
  }
}
