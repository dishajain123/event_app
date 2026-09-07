import '../../../../core/network/dio_exception_mapper.dart';
import 'certificates_api.dart';
import 'models/certificate.dart';

class CertificatesRepository {
  final CertificatesApi api;
  const CertificatesRepository(this.api);
  Future<List<AppCertificate>> listMine() async {
    try {
      return await api.listMine();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppCertificate> getMine(String certificateId) async {
    try {
      return await api.getMine(certificateId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<AppBadgeAward>> listBadges() async {
    try {
      return await api.listBadges();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  String artifactUrl(AppCertificate certificate) =>
      api.artifactUrl(certificate);
}
