import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../application/assistance_providers.dart';

class RequestAssistanceScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String registrationId;

  const RequestAssistanceScreen(
      {super.key, required this.eventId, required this.registrationId});

  @override
  ConsumerState<RequestAssistanceScreen> createState() =>
      _RequestAssistanceScreenState();
}

class _RequestAssistanceScreenState
    extends ConsumerState<RequestAssistanceScreen> {
  final _reasonController = TextEditingController();
  final _amountController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Please explain why you need assistance.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repository = ref.read(assistanceRepositoryProvider);
      await repository.createRequest(
        eventId: widget.eventId,
        registrationId: widget.registrationId,
        reason: reason,
        requestedFeeWaiverAmount: _amountController.text.trim().isEmpty
            ? null
            : double.tryParse(_amountController.text.trim()),
      );
      ref.invalidate(myAssistanceRequestsProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your request has been submitted.')),
        );
      }
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Assistance')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              controller: _reasonController,
              label: 'Why do you need assistance?',
              maxLines: 4,
              hint: 'Briefly explain your situation',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _amountController,
              label: 'Amount requested (optional)',
              hint: 'Leave blank to let the reviewer decide',
              keyboardType: TextInputType.number,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
                label: 'Submit request',
                fullWidth: true,
                loading: _submitting,
                onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
