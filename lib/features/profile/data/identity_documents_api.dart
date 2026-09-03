import 'package:dio/dio.dart';
import 'models/identity_document.dart';

/// Mirrors `app/modules/identity/router.py`'s identity-document
/// endpoints, including GET /users/me/identity-documents — added and
/// verified live this session specifically because the service's
/// list_identity_documents() already existed correctly implemented but
/// had no router endpoint at all.
class IdentityDocumentsApi {
  final Dio _dio;
  const IdentityDocumentsApi(this._dio);

  Future<IdentityDocument> upload({required DocumentType documentType, required String documentNumber}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users/me/identity-documents',
      data: {'document_type': documentType.wireValue, 'document_number': documentNumber},
    );
    return IdentityDocument.fromJson(response.data!);
  }

  Future<List<IdentityDocument>> listMine() async {
    final response = await _dio.get<List<dynamic>>('/users/me/identity-documents');
    return response.data!.map((item) => IdentityDocument.fromJson(item as Map<String, dynamic>)).toList();
  }
}
