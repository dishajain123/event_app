import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/assistance_api.dart';
import '../data/assistance_repository.dart';
import '../data/models/assistance_request.dart';

final assistanceRepositoryProvider = Provider<AssistanceRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AssistanceRepository(AssistanceApi(dio));
});

final myAssistanceRequestsProvider =
    FutureProvider<List<AssistanceRequest>>((ref) async {
  final repository = ref.watch(assistanceRepositoryProvider);
  return repository.listMine();
});
