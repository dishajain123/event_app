import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// Builds the single [Dio] instance the entire app shares. Every
/// `features/<name>/data/<name>_api.dart` receives this instance (via a
/// Riverpod provider — see core/providers/core_providers.dart) rather than
/// constructing its own, so base URL, timeouts, auth handling, and logging
/// are configured in exactly one place.
Dio createApiClient({
  required AppConfig config,
  required AuthInterceptor authInterceptor,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(authInterceptor);

  if (config.enableNetworkLogging && !config.isProduction) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        // Never log the Authorization header's value — request/response
        // bodies are useful for debugging, a bearer token in a log is not
        // something that should ever exist even in a debug build.
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  return dio;
}
