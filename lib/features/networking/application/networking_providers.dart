import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/models/networking.dart';
import '../data/networking_api.dart';
import '../data/networking_repository.dart';

final networkingRepositoryProvider = Provider<NetworkingRepository>(
    (ref) => NetworkingRepository(NetworkingApi(ref.watch(apiClientProvider))));
final networkingProfileProvider =
    FutureProvider.family<NetworkingProfile, String>(
        (ref, id) => ref.watch(networkingRepositoryProvider).profile(id));
final networkingParticipantsProvider =
    FutureProvider.family<NetworkingParticipantPage, String>(
        (ref, id) => ref.watch(networkingRepositoryProvider).discover(id));
final networkingConnectionsProvider =
    FutureProvider.family<List<NetworkingConnection>, String>(
        (ref, id) => ref.watch(networkingRepositoryProvider).connections(id));
