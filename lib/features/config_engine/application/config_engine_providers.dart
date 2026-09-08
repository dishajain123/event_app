import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/config_engine_api.dart';
import '../data/config_engine_repository.dart';
import '../data/models/configurable_field.dart';
import '../data/models/event_configuration.dart';

final configEngineRepositoryProvider = Provider<ConfigEngineRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ConfigEngineRepository(ConfigEngineApi(dio));
});

final eventConfigurationProvider =
    FutureProvider.family<EventConfiguration?, String>((ref, eventId) async {
  final repository = ref.watch(configEngineRepositoryProvider);
  return repository.getConfiguration(eventId);
});

typedef FieldSchemaQuery = ({String eventId, String participationType});

final eventFieldSchemaProvider =
    FutureProvider.family<EventFieldSchema?, FieldSchemaQuery>(
        (ref, query) async {
  final repository = ref.watch(configEngineRepositoryProvider);
  return repository.getFieldSchema(query.eventId, query.participationType);
});
