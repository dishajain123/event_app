import '../../../../core/network/dio_exception_mapper.dart';
import 'models/waitlist_entry.dart';
import 'waitlists_api.dart';

class WaitlistsRepository {
  final WaitlistsApi _api;
  const WaitlistsRepository(this._api);

  Future<WaitlistEntry> join(
      {required String eventId,
      required String participationType,
      String? childId,
      String? teamId}) async {
    try {
      return await _api.join(
          eventId: eventId,
          participationType: participationType,
          childId: childId,
          teamId: teamId);
    } catch (error) {
      throw mapDioException(error);
    }
  }

  Future<List<WaitlistEntry>> listMine() async {
    try {
      return await _api.listMine();
    } catch (error) {
      throw mapDioException(error);
    }
  }

  Future<WaitlistEntry> leave(String entryId) async {
    try {
      return await _api.leave(entryId);
    } catch (error) {
      throw mapDioException(error);
    }
  }
}
