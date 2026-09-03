import 'package:dio/dio.dart';
import 'models/referral.dart';

/// Mirrors `app/modules/referrals/router.py`'s participant-facing
/// endpoints. GET /mine auto-creates a referral profile on first access
/// (confirmed against get_or_create_profile in the service) — no
/// separate "opt in" call is needed.
class ReferralsApi {
  final Dio _dio;
  const ReferralsApi(this._dio);

  Future<MyReferral> getMine(String eventId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/referrals/mine',
      queryParameters: {'event_id': eventId},
    );
    return MyReferral.fromJson(response.data!);
  }
}
