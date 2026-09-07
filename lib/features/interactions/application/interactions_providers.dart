import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/interactions_api.dart';
import '../data/interactions_repository.dart';
import '../data/models/interaction.dart';

final interactionsRepositoryProvider = Provider<InteractionsRepository>((ref) =>
    InteractionsRepository(InteractionsApi(ref.watch(apiClientProvider))));
final eventPollsProvider = FutureProvider.family<List<EventPoll>, String>(
    (ref, id) => ref.watch(interactionsRepositoryProvider).polls(id));
final eventQuestionsProvider =
    FutureProvider.family<List<EventQuestion>, String>(
        (ref, id) => ref.watch(interactionsRepositoryProvider).questions(id));
