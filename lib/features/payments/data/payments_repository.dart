import '../../../core/network/dio_exception_mapper.dart';
import 'models/payment.dart';
import 'payments_api.dart';

class PaymentsRepository {
  final PaymentsApi _api;
  const PaymentsRepository(this._api);

  Future<PaymentGatewayOrder> initiatePayment({required String registrationId, String? discountCode}) async {
    try {
      return await _api.initiatePayment(registrationId: registrationId, discountCode: discountCode);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppPayment> confirmPayment({
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String gatewaySignature,
  }) async {
    try {
      return await _api.confirmPayment(
        gatewayOrderId: gatewayOrderId,
        gatewayPaymentId: gatewayPaymentId,
        gatewaySignature: gatewaySignature,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
