import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/models/sponsorship.dart';
import '../data/sponsorship_api.dart';
import '../data/sponsorship_repository.dart';

final sponsorshipRepositoryProvider = Provider<SponsorshipRepository>((ref) {
  return SponsorshipRepository(SponsorshipApi(ref.watch(apiClientProvider)));
});

final sponsorshipCategoriesProvider =
    FutureProvider<List<SponsorshipCategory>>((ref) {
  return ref.watch(sponsorshipRepositoryProvider).listCategories();
});

final sponsorshipPackagesProvider =
    FutureProvider<List<SponsorshipPackage>>((ref) {
  return ref.watch(sponsorshipRepositoryProvider).listPackages();
});

final mySponsorshipInquiriesProvider =
    FutureProvider<List<SponsorshipInquiry>>((ref) {
  return ref.watch(sponsorshipRepositoryProvider).listMine();
});
