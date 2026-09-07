import 'package:dio/dio.dart';
import 'models/certificate.dart';

class CertificatesApi {
  final Dio _dio;
  const CertificatesApi(this._dio);
  Future<List<AppCertificate>> listMine() async {
    final response = await _dio.get<Map<String, dynamic>>('/certificates/mine',
        queryParameters: {'page': 1, 'page_size': 50});
    return (response.data?['items'] as List<dynamic>? ?? [])
        .map((item) => AppCertificate.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AppCertificate> getMine(String certificateId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('/certificates/mine/$certificateId');
    return AppCertificate.fromJson(response.data!);
  }

  Future<List<AppBadgeAward>> listBadges() async {
    final response = await _dio.get<List<dynamic>>('/badges/mine');
    return (response.data ?? [])
        .map((item) => AppBadgeAward.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String artifactUrl(AppCertificate certificate) =>
      Uri.parse(_dio.options.baseUrl)
          .resolve(certificate.artifactUrl ?? '')
          .toString();
}
