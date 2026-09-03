import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/identity_documents_api.dart';
import '../data/identity_documents_repository.dart';
import '../data/models/identity_document.dart';

final identityDocumentsRepositoryProvider = Provider<IdentityDocumentsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return IdentityDocumentsRepository(IdentityDocumentsApi(dio));
});

final myIdentityDocumentsProvider = FutureProvider<List<IdentityDocument>>((ref) async {
  final repository = ref.watch(identityDocumentsRepositoryProvider);
  return repository.listMine();
});
