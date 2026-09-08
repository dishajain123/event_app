import 'package:dio/dio.dart';
import 'models/assistance_request.dart';

/// Mirrors `app/modules/assistance/router.py`'s participant-facing
/// endpoints, including GET /mine — added and verified live this session
/// specifically because a requester previously had no way to check on a
/// request they'd submitted (list_requests is Event-Manager-only).
class AssistanceApi {
  final Dio _dio;
  const AssistanceApi(this._dio);

  Future<AssistanceRequest> createRequest({
    required String eventId,
    required String registrationId,
    required String reason,
    double? requestedFeeWaiverAmount,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/assistance-requests',
      queryParameters: {'event_id': eventId},
      data: {
        'registration_id': registrationId,
        'reason': reason,
        if (requestedFeeWaiverAmount != null)
          'requested_fee_waiver_amount': requestedFeeWaiverAmount,
      },
    );
    return AssistanceRequest.fromJson(response.data!);
  }

  Future<List<AssistanceRequest>> listMine() async {
    final response = await _dio.get<List<dynamic>>('/assistance-requests/mine');
    return response.data!
        .map((item) => AssistanceRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
