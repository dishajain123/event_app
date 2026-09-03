import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tickets/application/tickets_providers.dart';
import '../data/check_in_repository.dart';
import '../data/offline_check_in_queue.dart';

final offlineCheckInQueueProvider = Provider<OfflineCheckInQueue>((ref) {
  return OfflineCheckInQueue();
});

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  final ticketsRepository = ref.watch(ticketsRepositoryProvider);
  final queue = ref.watch(offlineCheckInQueueProvider);
  return CheckInRepository(ticketsRepository, queue);
});
