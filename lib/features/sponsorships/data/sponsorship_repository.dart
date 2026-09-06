import 'sponsorship_api.dart';
import 'models/sponsorship.dart';

class SponsorshipRepository {
  final SponsorshipApi _api;
  const SponsorshipRepository(this._api);

  Future<List<SponsorshipCategory>> listCategories() => _api.listCategories();
  Future<List<SponsorshipPackage>> listPackages() => _api.listPackages();
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
  }) =>
      _api.createInquiry(
        companyName: companyName,
        contactPerson: contactPerson,
        phone: phone,
        email: email,
        businessDetails: businessDetails,
        categoryId: categoryId,
        packageId: packageId,
        eventIds: eventIds,
        offerDetails: offerDetails,
        message: message,
      );

  Future<List<SponsorshipInquiry>> listMine() => _api.listMine();
}
