import '../../../core/network/dio_exception_mapper.dart';
import 'assistance_api.dart';
import 'models/assistance_request.dart';

class AssistanceRepository {
  final AssistanceApi _api;
  const AssistanceRepository(this._api);

  Future<AssistanceRequest> createRequest({
    required String eventId,
    required String registrationId,
    required String reason,
    double? requestedFeeWaiverAmount,
  }) async {
    try {
      return await _api.createRequest(
        eventId: eventId,
        registrationId: registrationId,
        reason: reason,
        requestedFeeWaiverAmount: requestedFeeWaiverAmount,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<AssistanceRequest>> listMine() async {
    try {
      return await _api.listMine();
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
