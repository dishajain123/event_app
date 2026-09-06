import 'package:dio/dio.dart';
import 'models/payment.dart';

/// Mirrors `app/modules/payments/router.py`'s participant-facing
/// endpoints. Note there is no GET /payments/mine or GET /payments/{id}
/// (confirmed against the live router — GET "" is Finance-role-only) —
/// mobile confirms a payment's outcome by re-fetching the REGISTRATION
/// (which the backend flips to `confirmed` once the webhook fires), not
/// by polling a payment resource directly. See PaymentsRepository.
class PaymentsApi {
  final Dio _dio;
  const PaymentsApi(this._dio);

  Future<PaymentGatewayOrder> initiatePayment({required String registrationId, String? discountCode}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/payments/initiate',
      data: {
        'registration_id': registrationId,
        if (discountCode != null) 'discount_code': discountCode,
      },
    );
    return PaymentGatewayOrder.fromJson(response.data!);
  }

  /// Closes the loop after Razorpay's checkout sheet reports success.
  /// Razorpay's client SDK returns order id, payment id, and signature to
  /// the success callback. The app uses the authenticated verification
  /// endpoint; the webhook endpoint is reserved for gateway delivery.
  Future<AppPayment> confirmPayment({
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String gatewaySignature,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/payments/verify',
      data: {
        'gateway_order_id': gatewayOrderId,
        'gateway_payment_id': gatewayPaymentId,
        'gateway_signature': gatewaySignature,
      },
    );
    return AppPayment.fromJson(response.data!);
  }
}
