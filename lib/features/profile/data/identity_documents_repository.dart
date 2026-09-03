import '../../../core/network/dio_exception_mapper.dart';
import 'identity_documents_api.dart';
import 'models/identity_document.dart';

class IdentityDocumentsRepository {
  final IdentityDocumentsApi _api;
  const IdentityDocumentsRepository(this._api);

  Future<IdentityDocument> upload({required DocumentType documentType, required String documentNumber}) async {
    try {
      return await _api.upload(documentType: documentType, documentNumber: documentNumber);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<IdentityDocument>> listMine() async {
    try {
      return await _api.listMine();
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
