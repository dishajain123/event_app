import '../../../../core/utils/flexible_decimal.dart';

/// Mirrors `app/modules/payments/models.py`'s `PaymentStatus` StrEnum
/// exactly.
enum PaymentStatus {
  initiated('initiated'),
  verified('verified'),
  failed('failed'),
  refunded('refunded');

  final String wireValue;
  const PaymentStatus(this.wireValue);

  static PaymentStatus fromWire(String value) {
    return PaymentStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () =>
          throw FormatException('Unknown payment status from backend: $value'),
    );
  }

  String get label => switch (this) {
        PaymentStatus.initiated => 'Initiated',
        PaymentStatus.verified => 'Verified',
        PaymentStatus.failed => 'Failed',
        PaymentStatus.refunded => 'Refunded',
      };
}

/// Mirrors `app/modules/payments/schemas.py`'s `PaymentGatewayOrderOut`
/// exactly — the response to POST /payments/initiate. `amount` is in
/// whole currency units (rupees), NOT paise — confirmed directly against
/// the router (`amount=payment.amount`, the stored Decimal). Razorpay's
/// checkout SDK needs paise, so the conversion (`amountInPaise`) happens
/// once, here, rather than being repeated wherever this is used.
class PaymentGatewayOrder {
  final String paymentId;
  final String gatewayOrderId;
  final double amount;
  final String currency;
  final String keyId;

  const PaymentGatewayOrder({
    required this.paymentId,
    required this.gatewayOrderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory PaymentGatewayOrder.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayOrder(
      paymentId: json['payment_id'] as String,
      gatewayOrderId: json['gateway_order_id'] as String,
      amount: parseFlexibleDecimal(json['amount']) ?? 0,
      currency: json['currency'] as String,
      keyId: json['key_id'] as String,
    );
  }

  int get amountInPaise => (amount * 100).round();
}

/// Mirrors `app/modules/payments/schemas.py`'s `PaymentOut` exactly.
class AppPayment {
  final String id;
  final String eventId;
  final String registrationId;
  final String userId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String gatewayProvider;
  final String? gatewayOrderId;
  final String? gatewayPaymentId;
  final DateTime? verifiedAt;
  final DateTime? capturedAt;
  final DateTime createdAt;
  final String reconciliationStatus;
  final String? reconciliationError;

  const AppPayment({
    required this.id,
    required this.eventId,
    required this.registrationId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.gatewayProvider,
    required this.gatewayOrderId,
    required this.gatewayPaymentId,
    required this.verifiedAt,
    required this.capturedAt,
    required this.createdAt,
    this.reconciliationStatus = 'not_required',
    this.reconciliationError,
  });

  factory AppPayment.fromJson(Map<String, dynamic> json) {
    return AppPayment(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      registrationId: json['registration_id'] as String,
      userId: json['user_id'] as String,
      amount: parseFlexibleDecimal(json['amount']) ?? 0,
      currency: json['currency'] as String,
      status: PaymentStatus.fromWire(json['status'] as String),
      gatewayProvider: json['gateway_provider'] as String,
      gatewayOrderId: json['gateway_order_id'] as String?,
      gatewayPaymentId: json['gateway_payment_id'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      capturedAt: json['captured_at'] != null
          ? DateTime.parse(json['captured_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      reconciliationStatus:
          json['reconciliation_status'] as String? ?? 'not_required',
      reconciliationError: json['reconciliation_error'] as String?,
    );
  }
}
