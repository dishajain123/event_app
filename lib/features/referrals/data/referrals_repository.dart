import '../../../core/network/dio_exception_mapper.dart';
import 'models/referral.dart';
import 'referrals_api.dart';

class ReferralsRepository {
  final ReferralsApi _api;
  const ReferralsRepository(this._api);

  Future<MyReferral> getMine(String eventId) async {
    try {
      return await _api.getMine(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
