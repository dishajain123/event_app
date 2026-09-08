import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/models/registration.dart';
import '../data/registrations_api.dart';
import '../data/registrations_repository.dart';

final registrationsRepositoryProvider =
    Provider<RegistrationsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return RegistrationsRepository(RegistrationsApi(dio));
});

final myRegistrationsProvider =
    FutureProvider<List<AppRegistration>>((ref) async {
  final repository = ref.watch(registrationsRepositoryProvider);
  return repository.listMyRegistrations();
});

final registrationDetailProvider =
    FutureProvider.family<AppRegistration, String>((ref, registrationId) async {
  final repository = ref.watch(registrationsRepositoryProvider);
  return repository.getRegistration(registrationId);
});

final cancelRegistrationProvider =
    Provider<Future<AppRegistration> Function(String, {String? reason})>((ref) {
  final repository = ref.watch(registrationsRepositoryProvider);
  return (registrationId, {String? reason}) =>
      repository.cancelRegistration(registrationId, reason: reason);
});
