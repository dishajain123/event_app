import '../../../core/network/dio_exception_mapper.dart';
import 'models/ticket.dart';
import 'tickets_api.dart';

class TicketsRepository {
  final TicketsApi _api;
  const TicketsRepository(this._api);

  Future<List<AppTicket>> listMyTickets() async {
    try {
      return await _api.listMyTickets();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppTicket> getTicket(String ticketId) async {
    try {
      return await _api.getTicket(ticketId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppTicket> resolveByScan({required String scanPayload, required String qrSignature}) async {
    try {
      return await _api.resolveByScan(scanPayload: scanPayload, qrSignature: qrSignature);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppTicket> resolveByCode(String ticketCode) async {
    try {
      return await _api.resolveByCode(ticketCode);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> checkIn(String ticketId, {String? venueId, String? scanPayload}) async {
    try {
      await _api.checkIn(ticketId, venueId: venueId, scanPayload: scanPayload);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> syncOneOfflineCheckIn(Map<String, dynamic> scan) async {
    try {
      await _api.syncOneOfflineCheckIn(scan);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
