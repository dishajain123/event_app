import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../data/incidents_api.dart';
import '../data/incidents_repository.dart';
import '../data/models/incident.dart';

final incidentsRepositoryProvider = Provider<IncidentsRepository>(
    (ref) => IncidentsRepository(IncidentsApi(ref.watch(apiClientProvider))));
final incidentsProvider = FutureProvider.family<IncidentPage, String?>(
    (ref, eventId) =>
        ref.watch(incidentsRepositoryProvider).list(eventId: eventId));
