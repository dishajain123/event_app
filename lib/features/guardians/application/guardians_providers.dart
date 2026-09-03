import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/guardians_api.dart';
import '../data/guardians_repository.dart';
import '../data/models/child_profile.dart';

final guardiansRepositoryProvider = Provider<GuardiansRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return GuardiansRepository(GuardiansApi(dio));
});

final myChildrenProvider = FutureProvider<List<ChildProfile>>((ref) async {
  final repository = ref.watch(guardiansRepositoryProvider);
  return repository.listChildren();
});
