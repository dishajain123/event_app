/// A single scan captured while offline, held locally until
/// [OfflineCheckInQueue] syncs it via POST /check-ins/sync. Mirrors the
/// shape `OfflineCheckInIn` on the backend expects (Section 9).
class QueuedCheckIn {
  final String localId; // client-generated, for list rendering/removal only
  final String scanPayload;
  final String barcodeSignature;
  final String? venueId;
  final DateTime scannedAt;
  final String operationType;
  final String entityId;
  final int retryCount;
  final String? lastError;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QueuedCheckIn({
    required this.localId,
    required this.scanPayload,
    required this.barcodeSignature,
    required this.venueId,
    required this.scannedAt,
    this.operationType = 'offline_check_in',
    String? entityId,
    this.retryCount = 0,
    this.lastError,
    this.syncStatus = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : entityId = entityId ?? scanPayload,
        createdAt = createdAt ?? scannedAt,
        updatedAt = updatedAt ?? scannedAt;

  Map<String, dynamic> toJson() => {
        'local_id': localId,
        'scan_payload': scanPayload,
        'barcode_signature': barcodeSignature,
        'venue_id': venueId,
        'scanned_at': scannedAt.toIso8601String(),
        'operation_type': operationType,
        'entity_id': entityId,
        'retry_count': retryCount,
        'last_error': lastError,
        'sync_status': syncStatus,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
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
      operationType: json['operation_type'] as String? ?? 'offline_check_in',
      entityId: json['entity_id'] as String? ?? json['scan_payload'] as String,
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      lastError: json['last_error'] as String?,
      syncStatus: json['sync_status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.parse(json['scanned_at'] as String),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.parse(json['scanned_at'] as String),
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
