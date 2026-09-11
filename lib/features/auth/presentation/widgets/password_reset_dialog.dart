import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/app_exception.dart';
import '../../application/auth_state_provider.dart';

/// Controllers live with the dialog, including its dismissal animation.
class PasswordResetDialog extends ConsumerStatefulWidget {
  final String initialEmail;
  const PasswordResetDialog({super.key, required this.initialEmail});

  @override
  ConsumerState<PasswordResetDialog> createState() =>
      _PasswordResetDialogState();
}

class _PasswordResetDialogState extends ConsumerState<PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _codeSent = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final auth = ref.read(authStateProvider.notifier);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (!_codeSent) {
        await auth.requestPasswordReset(email);
        if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
        setState(() => _codeSent = true);
      } else {
        await auth.resetPassword(email: email, code: code, password: password);
        if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
        Navigator.of(context).pop(true);
      }
    } on AppException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_codeSent ? 'Enter reset code' : 'Reset password'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const ValueKey('reset-email'),
              controller: _emailController,
              readOnly: _codeSent || _submitting,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: (value) {
                final email = value?.trim() ?? '';
                return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
                    ? null
                    : 'Enter a valid email address.';
              },
            ),
            if (_codeSent) ...[
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('reset-code'),
                controller: _codeController,
                readOnly: _submitting,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Email code'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Enter the reset code from your email.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('reset-password'),
                controller: _passwordController,
                readOnly: _submitting,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'New password'),
                validator: (value) => (value?.length ?? 0) < 8
                    ? 'Use at least 8 characters.'
                    : null,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: Text(_submitting
              ? 'Please wait…'
              : (_codeSent ? 'Reset' : 'Send code')),
        ),
      ],
    );
  }
}
