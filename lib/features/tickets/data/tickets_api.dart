import 'package:dio/dio.dart';
import 'models/ticket.dart';

/// Mirrors `app/modules/tickets/router.py`'s participant + Staff-Mode-
/// scanner-facing endpoints.
class TicketsApi {
  final Dio _dio;
  const TicketsApi(this._dio);

  Future<List<AppTicket>> listMyTickets() async {
    final response = await _dio.get<List<dynamic>>('/tickets/mine');
    return response.data!
        .map((item) => AppTicket.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AppTicket> getTicket(String ticketId) async {
    final response = await _dio.get<Map<String, dynamic>>('/tickets/$ticketId');
    return AppTicket.fromJson(response.data!);
  }

  Future<void> transfer(String ticketId, String recipientUserId) async {
    await _dio.post<Map<String, dynamic>>('/tickets/$ticketId/transfer',
        data: {'recipient_user_id': recipientUserId});
  }

  Future<void> respondToTransfer(String transferId,
      {required bool accept}) async {
    await _dio.post<Map<String, dynamic>>(
        '/tickets/transfers/$transferId/${accept ? 'accept' : 'reject'}');
  }

  Future<List<TicketTransfer>> listIncomingTransfers() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tickets/transfers/mine',
      queryParameters: {'page': 1, 'page_size': 50},
    );
    return (response.data?['items'] as List<dynamic>? ?? [])
        .map((item) => TicketTransfer.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// The scanner's first call after every scan: a scanned barcode payload
  /// alone never contains the ticket's real
  /// UUID — this resolves it (and verifies the signature server-side)
  /// before POST /{ticket_id}/check-in can be called.
  Future<AppTicket> resolveByScan(
      {required String scanPayload, required String barcodeSignature}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/tickets/resolve',
      data: {
        'scan_payload': scanPayload,
        'barcode_signature': barcodeSignature
      },
    );
    return AppTicket.fromJson(response.data!);
  }

  Future<TicketValidation> validateScan(
      {required String scanPayload,
      required String barcodeSignature,
      String? eventId,
      String? accessZoneId}) async {
    final response = await _dio
        .post<Map<String, dynamic>>('/tickets/validate', queryParameters: {
      if (eventId != null) 'event_id': eventId,
      if (accessZoneId != null) 'access_zone_id': accessZoneId,
    }, data: {
      'scan_payload': scanPayload,
      'barcode_signature': barcodeSignature
    });
    return TicketValidation.fromJson(response.data!);
  }

  Future<void> checkIn(String ticketId,
      {String? venueId, String? scanPayload}) async {
    await _dio.post<Map<String, dynamic>>(
      '/tickets/$ticketId/check-in',
      data: {
        if (venueId != null) 'venue_id': venueId,
        if (scanPayload != null) 'scan_payload': scanPayload,
      },
    );
  }

  /// The manual-entry fallback for a damaged/unreadable barcode — looks up
  /// by ticket_code alone, no signature required (see the backend's
  /// resolve_by_ticket_code for why this narrower trust model is
  /// justified for this one fallback path).
  Future<AppTicket> resolveByCode(String ticketCode) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/tickets/by-code/$ticketCode');
    return AppTicket.fromJson(response.data!);
  }

  /// Deliberately sends exactly ONE scan per call rather than the whole
  /// queue as a single batch, even though POST /check-ins/sync accepts a
  /// list. Traced through the backend's real implementation: each scan
  /// in a batch is committed individually as it's processed, but if
  /// scan #3 of 10 then fails (e.g. a duplicate), the whole request
  /// returns an error and the CLIENT has no way to tell #1–2 actually
  /// succeeded server-side. One call per scan sidesteps that ambiguity
  /// completely — the repository's sync loop (see
  /// CheckInRepository.syncQueue) calls this once per queued item and
  /// removes only the ones that actually succeed.
  Future<void> syncOneOfflineCheckIn(Map<String, dynamic> scan) async {
    await _dio.post<List<dynamic>>('/check-ins/sync', data: {
      'scans': [scan]
    });
  }
}
