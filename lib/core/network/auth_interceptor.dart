import 'package:dio/dio.dart';
import '../storage/secure_token_storage.dart';

/// Attaches the stored access token to every request, and on a 401,
/// attempts exactly one refresh before retrying the original request once.
///
/// Concurrent 401s are coalesced into a single refresh call — if three
/// requests all fail with 401 at roughly the same moment (e.g. a screen
/// that fires several calls in parallel right as the token expires), only
/// the first one triggers [refreshToken]; the other two wait on the same
/// in-flight future rather than each starting their own refresh. This is
/// the same pattern already proven in the web console's API client,
/// adapted from a JS Promise to a Dart Future.
///
/// This class deliberately does NOT depend on the auth feature's
/// repository directly — [refreshToken] and [onSessionExpired] are
/// injected callbacks, wired up where the Dio instance is actually built
/// (see core/providers/core_providers.dart), so core/network/ never has to
/// import features/auth/ and risk a circular dependency.
class AuthInterceptor extends Interceptor {
  final SecureTokenStorage tokenStorage;

  /// Returns the new access token on success, or null if the refresh
  /// itself failed (refresh token expired/invalid) — in which case the
  /// session is over and [onSessionExpired] is called.
  final Future<String?> Function() refreshToken;

  final void Function() onSessionExpired;

  AuthInterceptor({
    required this.tokenStorage,
    required this.refreshToken,
    required this.onSessionExpired,
  });

  Future<String?>? _pendingRefresh;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['_retriedAfterRefresh'] == true;

    // Never attempt to refresh the refresh call itself, or anything already retried once.
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/');

    if (!isUnauthorized || alreadyRetried || isAuthEndpoint) {
      handler.next(err);
      return;
    }

    final newToken = await _refreshOnce();
    if (newToken == null) {
      onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.extra['_retriedAfterRefresh'] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';

      final dio = Dio(BaseOptions(baseUrl: retryOptions.baseUrl));
      final response = await dio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshOnce() {
    _pendingRefresh ??= refreshToken().whenComplete(() {
      _pendingRefresh = null;
    });
    return _pendingRefresh!;
  }
}
