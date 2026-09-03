import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../storage/secure_token_storage.dart';

/// Read once at startup (see main_development.dart etc.) and overridden
/// into the ProviderScope — nothing computes its own AppConfig.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden in main.dart before runApp.');
});

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});

/// A second, bare Dio instance used ONLY to call POST /auth/refresh.
///
/// This exists specifically to avoid a circular dependency: the main
/// [apiClientProvider]'s AuthInterceptor needs a way to call the refresh
/// endpoint when it sees a 401, but the refresh call itself must never go
/// through that same interceptor (attaching an expired access token to a
/// refresh call, or worse, trying to refresh-and-retry a refresh call that
/// itself 401s, would recurse). A separate, interceptor-free Dio instance
/// makes that structurally impossible rather than something to remember.
final _refreshOnlyDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  return Dio(BaseOptions(baseUrl: config.apiBaseUrl, headers: {'Content-Type': 'application/json'}));
});

/// Set by the auth feature once it's initialized (see
/// features/auth/application/auth_state_provider.dart) — called whenever
/// the interceptor determines the session is over (refresh failed). Kept
/// as a simple mutable holder rather than a full provider dependency so
/// core/network never has to import features/auth/.
final sessionExpiredNotifierProvider = Provider<SessionExpiredNotifier>((ref) {
  return SessionExpiredNotifier();
});

class SessionExpiredNotifier {
  void Function()? _listener;

  void setListener(void Function() listener) => _listener = listener;

  void notify() => _listener?.call();
}

final apiClientProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  final refreshDio = ref.watch(_refreshOnlyDioProvider);
  final sessionExpiredNotifier = ref.watch(sessionExpiredNotifierProvider);

  final authInterceptor = AuthInterceptor(
    tokenStorage: tokenStorage,
    onSessionExpired: sessionExpiredNotifier.notify,
    refreshToken: () async {
      final storedRefreshToken = await tokenStorage.getRefreshToken();
      if (storedRefreshToken == null || storedRefreshToken.isEmpty) return null;

      try {
        final response = await refreshDio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refresh_token': storedRefreshToken},
        );
        final newAccessToken = response.data?['access_token'] as String?;
        final newRefreshToken = response.data?['refresh_token'] as String?;
        if (newAccessToken == null) return null;

        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? storedRefreshToken,
        );
        return newAccessToken;
      } on DioException {
        return null;
      }
    },
  );

  return createApiClient(config: config, authInterceptor: authInterceptor);
});
