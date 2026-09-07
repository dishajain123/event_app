import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/waitlists_api.dart';
import '../data/waitlists_repository.dart';
import '../data/models/waitlist_entry.dart';

final waitlistsRepositoryProvider = Provider<WaitlistsRepository>((ref) {
  return WaitlistsRepository(WaitlistsApi(ref.watch(apiClientProvider)));
});

final myWaitlistsProvider = FutureProvider<List<WaitlistEntry>>((ref) async {
  return ref.watch(waitlistsRepositoryProvider).listMine();
});

final joinWaitlistProvider = Provider<
    Future<WaitlistEntry> Function(
        {required String eventId,
        required String participationType,
        String? childId,
        String? teamId})>((ref) {
  final repository = ref.watch(waitlistsRepositoryProvider);
  return ({required eventId, required participationType, childId, teamId}) =>
      repository.join(
          eventId: eventId,
          participationType: participationType,
          childId: childId,
          teamId: teamId);
});
