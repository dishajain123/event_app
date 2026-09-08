import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/models/payment.dart';

/// Wraps `razorpay_flutter`'s checkout sheet behind a plain
/// callback-based interface, so nothing else in the app touches the
/// plugin's API directly.
///
/// IMPORTANT VERIFICATION NOTE: this file was written from training
/// knowledge of the `razorpay_flutter` package's public API (the
/// `Razorpay` class, `EVENT_PAYMENT_SUCCESS`/`EVENT_PAYMENT_ERROR`
/// constants, `PaymentSuccessResponse`/`PaymentFailureResponse` field
/// names) — this sandbox has no access to `pub.dev`, so the actual
/// installed package source could not be read to confirm this against
/// the real API surface, unlike every backend-facing model in this app,
/// which WAS checked line-by-line against your real schemas. Third-party
/// plugin APIs are exactly the kind of detail most likely to have
/// drifted from training knowledge. If `flutter pub get` succeeds but
/// this file fails to compile, this is the first place to look — the
/// fix should be small and contained to this one file, which is the
/// entire reason its usage is isolated here rather than spread across
/// PaymentCheckoutScreen.
class RazorpayCheckoutService {
  Razorpay? _razorpay;

  void open({
    required PaymentGatewayOrder order,
    String? userContact,
    String? userEmail,
    required void Function(String gatewayPaymentId, String gatewayOrderId,
            String gatewaySignature)
        onSuccess,
    required void Function(String message) onError,
  }) {
    final razorpay = Razorpay();
    _razorpay = razorpay;

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
        (PaymentSuccessResponse response) {
      onSuccess(
        response.paymentId ?? '',
        response.orderId ?? order.gatewayOrderId,
        response.signature ?? '',
      );
      dispose();
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse response) {
      onError(response.message ?? 'Payment failed or was cancelled.');
      dispose();
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
        (ExternalWalletResponse response) {
      // Informational only (e.g. Paytm selected as an external wallet) —
      // Razorpay's own checkout flow handles the wallet interaction;
      // nothing for this app to do here.
    });

    razorpay.open({
      'key': order.keyId,
      'amount': order.amountInPaise,
      'currency': order.currency,
      'order_id': order.gatewayOrderId,
      'name': 'Event Platform',
      if (userContact != null || userEmail != null)
        'prefill': {
          if (userContact != null) 'contact': userContact,
          if (userEmail != null) 'email': userEmail,
        },
    });
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
