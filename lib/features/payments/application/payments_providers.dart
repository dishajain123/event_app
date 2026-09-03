import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/payments_api.dart';
import '../data/payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return PaymentsRepository(PaymentsApi(dio));
});
