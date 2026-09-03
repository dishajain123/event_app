import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/network/app_exception.dart';
import '../../../tickets/data/models/ticket.dart';
import '../../../tickets/data/tickets_repository.dart';
import 'models/queued_check_in.dart';
import 'offline_check_in_queue.dart';

/// The outcome of a single scan, for the scanner screen to render
/// distinct visual/haptic feedback per Section 8's requirement (Phase 5:
/// "success/duplicate/invalid-ticket feedback states, each visually
/// distinct").
sealed class CheckInResult {
  const CheckInResult();
}

final class CheckInSuccess extends CheckInResult {
  final AppTicket ticket;
  const CheckInSuccess(this.ticket);
}

final class CheckInQueuedOffline extends CheckInResult {
  const CheckInQueuedOffline();
}

final class CheckInDuplicate extends CheckInResult {
  const CheckInDuplicate();
}

final class CheckInFailed extends CheckInResult {
  final String message;
  const CheckInFailed(this.message);
}

class SyncSummary {
  final int succeeded;
  final int failed;
  const SyncSummary({required this.succeeded, required this.failed});
}

class CheckInRepository {
  final TicketsRepository _ticketsRepository;
  final OfflineCheckInQueue _queue;
  final Connectivity _connectivity;
  int _localIdCounter = 0;

  CheckInRepository(this._ticketsRepository, this._queue, {Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// A locally-unique ID for queue list rendering/removal only — never
  /// sent anywhere as if it were a real backend ID. Deliberately not the
  /// `uuid` package: one more dependency this sandbox can't verify
  /// against the real installed source isn't worth taking on for
  /// something a timestamp + in-memory counter already solves
  /// perfectly well within a single app session (the only scope this ID
  /// needs to be unique within).
  String _generateLocalId() {
    _localIdCounter += 1;
    return '${DateTime.now().microsecondsSinceEpoch}-$_localIdCounter';
  }

  /// VERIFICATION NOTE (same caveat as razorpay_checkout_service.dart and
  /// ticket_detail_screen.dart): `connectivity_plus` v5+ changed
  /// `checkConnectivity()` to return `List<ConnectivityResult>` instead
  /// of a single value (to support multiple simultaneous connections) —
  /// written from training knowledge of that API change, not verified
  /// against the real installed v6.0.5 source.
  Future<bool> get _isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Called immediately after every camera scan. Online: resolves the
  /// ticket and checks it in against the real backend right away.
  /// Offline: the scan is written to the persisted queue BEFORE any
  /// network attempt (Section 13.2) and reported as queued, not failed —
  /// this is expected, correct behavior for a volunteer scanning at a
  /// gate with poor signal, not an error state.
  Future<CheckInResult> processScan({required String scanPayload, required String qrSignature, String? venueId}) async {
    final online = await _isOnline;

    if (!online) {
      await _queue.add(
        QueuedCheckIn(
          localId: _generateLocalId(),
          scanPayload: scanPayload,
          qrSignature: qrSignature,
          venueId: venueId,
          scannedAt: DateTime.now(),
        ),
      );
      return const CheckInQueuedOffline();
    }

    try {
      final ticket = await _ticketsRepository.resolveByScan(scanPayload: scanPayload, qrSignature: qrSignature);
      await _ticketsRepository.checkIn(ticket.id, venueId: venueId, scanPayload: scanPayload);
      return CheckInSuccess(ticket);
    } on AppException catch (e) {
      // A duplicate check-in is a distinct, expected outcome (someone
      // already scanned this ticket) — never a generic failure message.
      if (e is ValidationException && e.message.toLowerCase().contains('already')) {
        return const CheckInDuplicate();
      }
      return CheckInFailed(e.message);
    }
  }

  Future<List<QueuedCheckIn>> listQueued() => _queue.list();

  /// The manual-entry fallback (Section 8, Phase 5) — requires network
  /// (there's no meaningful offline story for a fallback path that's
  /// already the exception case), resolves by ticket_code alone (see
  /// TicketsApi.resolveByCode), then checks in exactly like the camera
  /// path.
  Future<CheckInResult> processManualEntry({required String ticketCode, String? venueId}) async {
    try {
      final ticket = await _ticketsRepository.resolveByCode(ticketCode.trim());
      await _ticketsRepository.checkIn(ticket.id, venueId: venueId);
      return CheckInSuccess(ticket);
    } on AppException catch (e) {
      if (e is ValidationException && e.message.toLowerCase().contains('already')) {
        return const CheckInDuplicate();
      }
      return CheckInFailed(e.message);
    }
  }

  /// Syncs the queue one item at a time (see TicketsApi.syncOneOfflineCheckIn
  /// for why) — only removing items that actually succeeded, so a
  /// partial-connectivity sync never silently drops a real scan.
  Future<SyncSummary> syncQueue() async {
    final items = await _queue.list();
    var succeeded = 0;
    var failed = 0;
    final toRemove = <String>{};

    for (final item in items) {
      try {
        await _ticketsRepository.syncOneOfflineCheckIn(item.toSyncPayload());
        toRemove.add(item.localId);
        succeeded++;
      } on AppException {
        failed++;
      }
    }

    if (toRemove.isNotEmpty) {
      await _queue.removeByLocalIds(toRemove);
    }
    return SyncSummary(succeeded: succeeded, failed: failed);
  }
}
