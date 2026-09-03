import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../auth/application/auth_state_provider.dart';
import '../../../registrations/application/registrations_providers.dart';
import '../../../tickets/application/tickets_providers.dart';
import '../../application/payments_providers.dart';
import '../../application/razorpay_checkout_service.dart';
import '../../data/models/payment.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  final String registrationId;
  const PaymentCheckoutScreen({super.key, required this.registrationId});

  @override
  ConsumerState<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends ConsumerState<PaymentCheckoutScreen> {
  final _checkoutService = RazorpayCheckoutService();
  PaymentGatewayOrder? _order;
  bool _initiating = false;
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _checkoutService.dispose();
    super.dispose();
  }

  Future<void> _initiate() async {
    setState(() {
      _initiating = true;
      _error = null;
    });
    try {
      final repository = ref.read(paymentsRepositoryProvider);
      final order = await repository.initiatePayment(registrationId: widget.registrationId);
      if (mounted) setState(() => _order = order);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _initiating = false);
    }
  }

  void _openCheckout() {
    final order = _order;
    if (order == null) return;

    final authState = ref.read(authStateProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    setState(() {
      _processing = true;
      _error = null;
    });

    _checkoutService.open(
      order: order,
      userContact: user?.mobileNumber,
      userEmail: user?.email,
      onSuccess: (paymentId, orderId, signature) async {
        await _confirmPayment(orderId, paymentId, signature);
      },
      onError: (message) {
        if (mounted) {
          setState(() {
            _processing = false;
            _error = message;
          });
        }
      },
    );
  }

  Future<void> _confirmPayment(String orderId, String paymentId, String signature) async {
    try {
      final repository = ref.read(paymentsRepositoryProvider);
      // By the time this call returns, the backend has already verified
      // the payment AND issued the ticket synchronously within the same
      // request (confirmed against handle_webhook's real implementation)
      // — no polling loop is needed here.
      await repository.confirmPayment(
        gatewayOrderId: orderId,
        gatewayPaymentId: paymentId,
        gatewaySignature: signature,
      );

      ref.invalidate(myRegistrationsProvider);
      ref.invalidate(registrationDetailProvider(widget.registrationId));
      ref.invalidate(myTicketsProvider);

      if (mounted) {
        context.go('/tickets/mine');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful — your ticket is ready.')),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _processing = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initiate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_initiating)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_order != null) ...[
                Text('Amount due', style: AppTypography.bodyMuted),
                const SizedBox(height: 4),
                Text(
                  '${_order!.currency} ${_order!.amount.toStringAsFixed(2)}',
                  style: AppTypography.display,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_error!, style: AppTypography.body.copyWith(color: AppColors.danger)),
                  ),
                const Spacer(),
                AppButton(
                  label: _processing ? 'Processing…' : 'Pay now',
                  fullWidth: true,
                  size: AppButtonSize.large,
                  loading: _processing,
                  onPressed: _processing ? null : _openCheckout,
                ),
              ] else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: AppTypography.body, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(label: 'Try again', onPressed: _initiate),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
