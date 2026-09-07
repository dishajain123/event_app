import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/certificates_api.dart';
import '../data/certificates_repository.dart';
import '../data/models/certificate.dart';

final certificatesRepositoryProvider = Provider<CertificatesRepository>((ref) =>
    CertificatesRepository(CertificatesApi(ref.watch(apiClientProvider))));
final myCertificatesProvider = FutureProvider<List<AppCertificate>>(
    (ref) => ref.watch(certificatesRepositoryProvider).listMine());
final myBadgesProvider = FutureProvider<List<AppBadgeAward>>(
    (ref) => ref.watch(certificatesRepositoryProvider).listBadges());
final certificateDetailProvider = FutureProvider.family<AppCertificate, String>(
    (ref, id) => ref.watch(certificatesRepositoryProvider).getMine(id));
