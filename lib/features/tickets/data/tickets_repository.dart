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

  Future<void> transfer(String ticketId, String recipientUserId) async {
    try {
      await _api.transfer(ticketId, recipientUserId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<TicketTransfer>> listIncomingTransfers() async {
    try {
      return await _api.listIncomingTransfers();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> respondToTransfer(String transferId,
      {required bool accept}) async {
    try {
      await _api.respondToTransfer(transferId, accept: accept);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppTicket> resolveByScan(
      {required String scanPayload, required String barcodeSignature}) async {
    try {
      return await _api.resolveByScan(
          scanPayload: scanPayload, barcodeSignature: barcodeSignature);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<TicketValidation> validateScan(
      {required String scanPayload,
      required String barcodeSignature,
      String? eventId,
      String? accessZoneId}) async {
    try {
      return await _api.validateScan(
          scanPayload: scanPayload,
          barcodeSignature: barcodeSignature,
          eventId: eventId,
          accessZoneId: accessZoneId);
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

  Future<void> checkIn(String ticketId,
      {String? venueId, String? scanPayload}) async {
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
