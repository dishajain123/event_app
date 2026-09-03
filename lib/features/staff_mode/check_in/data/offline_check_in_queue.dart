import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/queued_check_in.dart';

const _queueKey = 'event_app.offline_check_in_queue';

/// A scan is written to disk the moment it's captured — before any
/// network attempt — so a force-close or crash mid-queue never loses an
/// already-scanned ticket (Section 13.2's risk mitigation for exactly
/// this). This is deliberately plain [SharedPreferences] JSON, not a
/// database — the queue is expected to hold at most a few dozen entries
/// between sync windows, not a large dataset.
class OfflineCheckInQueue {
  Future<List<QueuedCheckIn>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => QueuedCheckIn.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> add(QueuedCheckIn item) async {
    final current = await list();
    current.add(item);
    await _save(current);
  }

  Future<void> removeByLocalIds(Set<String> localIds) async {
    final current = await list();
    current.removeWhere((item) => localIds.contains(item.localId));
    await _save(current);
  }

  Future<void> _save(List<QueuedCheckIn> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_queueKey, encoded);
  }
}
