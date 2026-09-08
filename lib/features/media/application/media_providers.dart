import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/media_api.dart';
import '../data/media_repository.dart';
import '../data/models/event_media.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return MediaRepository(MediaApi(dio));
});

final eventMediaProvider =
    FutureProvider.family<List<EventMedia>, String>((ref, eventId) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return repository.listEventMedia(eventId);
});
