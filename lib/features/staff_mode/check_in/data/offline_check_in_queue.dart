import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/queued_check_in.dart';

const _queueKey = 'event_app.offline_check_in_queue';

/// A scan is written to disk the moment it's captured — before any
/// network attempt — so a force-close or crash mid-queue never loses an
/// already-scanned ticket (Section 13.2's risk mitigation for exactly
/// this). This uses encrypted key-value JSON, not a database — the queue is
/// expected to hold at most a few dozen entries between sync windows, not a
/// large dataset.
class OfflineCheckInQueue {
  static const _storage = FlutterSecureStorage();

  Future<List<QueuedCheckIn>> list() async {
    var raw = await _storage.read(key: _queueKey);
    if (raw == null || raw.isEmpty) {
      final legacyPrefs = await SharedPreferences.getInstance();
      final legacyRaw = legacyPrefs.getString(_queueKey);
      if (legacyRaw != null && legacyRaw.isNotEmpty) {
        raw = legacyRaw;
        await _storage.write(key: _queueKey, value: legacyRaw);
        await legacyPrefs.remove(_queueKey);
      }
    }
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => QueuedCheckIn.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> add(QueuedCheckIn item) async {
    final current = await list();
    if (current.any((existing) =>
        existing.scanPayload == item.scanPayload &&
        existing.barcodeSignature == item.barcodeSignature &&
        existing.syncStatus == 'pending')) {
      return false;
    }
    current.add(item);
    current.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (current.length > 500) {
      current.removeWhere((item) => item.syncStatus == 'failed');
      if (current.length > 500) current.removeRange(0, current.length - 500);
    }
    await _save(current);
    return true;
  }

  Future<void> update(QueuedCheckIn updated) async {
    final current = await list();
    final index = current.indexWhere((item) => item.localId == updated.localId);
    if (index == -1) return;
    current[index] = updated;
    await _save(current);
  }

  Future<void> removeByLocalIds(Set<String> localIds) async {
    final current = await list();
    current.removeWhere((item) => localIds.contains(item.localId));
    await _save(current);
  }

  Future<void> _save(List<QueuedCheckIn> items) async {
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await _storage.write(key: _queueKey, value: encoded);
  }
}
