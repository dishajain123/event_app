import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/models/referral.dart';
import '../data/referrals_api.dart';
import '../data/referrals_repository.dart';

final referralsRepositoryProvider = Provider<ReferralsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ReferralsRepository(ReferralsApi(dio));
});

final myReferralProvider =
    FutureProvider.family<MyReferral, String>((ref, eventId) async {
  final repository = ref.watch(referralsRepositoryProvider);
  return repository.getMine(eventId);
});
