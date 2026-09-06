import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/models/volunteer_application.dart';
import '../data/volunteer_api.dart';
import '../data/volunteer_repository.dart';

final volunteerRepositoryProvider = Provider<VolunteerRepository>(
    (ref) => VolunteerRepository(VolunteerApi(ref.watch(apiClientProvider))));

final myVolunteerApplicationsProvider =
    FutureProvider<List<VolunteerApplication>>(
        (ref) => ref.watch(volunteerRepositoryProvider).listMine());
