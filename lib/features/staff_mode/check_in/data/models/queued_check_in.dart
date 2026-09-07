/// A single scan captured while offline, held locally until
/// [OfflineCheckInQueue] syncs it via POST /check-ins/sync. Mirrors the
/// shape `OfflineCheckInIn` on the backend expects (Section 9).
class QueuedCheckIn {
  final String localId; // client-generated, for list rendering/removal only
  final String scanPayload;
  final String barcodeSignature;
  final String? venueId;
  final DateTime scannedAt;

  const QueuedCheckIn({
    required this.localId,
    required this.scanPayload,
    required this.barcodeSignature,
    required this.venueId,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
        'local_id': localId,
        'scan_payload': scanPayload,
        'barcode_signature': barcodeSignature,
        'venue_id': venueId,
        'scanned_at': scannedAt.toIso8601String(),
      };

  factory QueuedCheckIn.fromJson(Map<String, dynamic> json) {
    return QueuedCheckIn(
      localId: json['local_id'] as String,
      scanPayload: json['scan_payload'] as String,
      // Read the old local queue key once so an app upgrade does not lose
      // scans captured before the barcode migration.
      barcodeSignature:
          (json['barcode_signature'] ?? json['qr_signature']) as String,
      venueId: json['venue_id'] as String?,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
    );
  }

  /// The exact shape POST /check-ins/sync expects for one entry in `scans`.
  Map<String, dynamic> toSyncPayload() => {
        'scan_payload': scanPayload,
        'barcode_signature': barcodeSignature,
        if (venueId != null) 'venue_id': venueId,
        'offline_batch_id': localId,
      };
}
