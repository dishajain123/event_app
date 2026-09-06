import 'package:dio/dio.dart';
import 'models/sponsorship.dart';

class SponsorshipApi {
  final Dio _dio;
  const SponsorshipApi(this._dio);

  Future<List<SponsorshipCategory>> listCategories() async {
    final response = await _dio.get<List<dynamic>>('/sponsorship/categories');
    return response.data!
        .map((item) =>
            SponsorshipCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<SponsorshipPackage>> listPackages() async {
    final response = await _dio.get<List<dynamic>>('/sponsorship/packages');
    return response.data!
        .map(
            (item) => SponsorshipPackage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SponsorshipInquiry> createInquiry({
    required String companyName,
    required String contactPerson,
    required String phone,
    required String email,
    String? businessDetails,
    String? categoryId,
    String? packageId,
    required List<String> eventIds,
    String? offerDetails,
    String? message,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sponsorship/inquiries',
      data: {
        'company_name': companyName,
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        if (businessDetails != null && businessDetails.isNotEmpty)
          'business_details': businessDetails,
        if (categoryId != null) 'category_id': categoryId,
        if (packageId != null) 'package_id': packageId,
        'event_ids': eventIds,
        if (offerDetails != null && offerDetails.isNotEmpty)
          'offer_details': offerDetails,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
    return SponsorshipInquiry.fromJson(response.data!);
  }

  Future<List<SponsorshipInquiry>> listMine() async {
    final response =
        await _dio.get<List<dynamic>>('/sponsorship/inquiries/mine');
    return response.data!
        .map(
            (item) => SponsorshipInquiry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
