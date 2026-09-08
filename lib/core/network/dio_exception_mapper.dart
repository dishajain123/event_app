import 'package:dio/dio.dart';
import 'app_exception.dart';

/// Every repository's Dio call is wrapped in a try/catch that funnels
/// through this one function — the single place a [DioException] (or any
/// other exception a network call can throw) becomes the typed
/// [AppException] every screen's error UI actually branches on (Section 3.7).
///
/// This is deliberately a plain function, not baked into a Dio interceptor:
/// interceptors are for cross-cutting behavior that must run on every
/// request (auth headers, refresh-retry — see [AuthInterceptor]); mapping a
/// failure into the shape the UI wants is a per-call concern each
/// repository is explicit about, which keeps a stack trace pointing at the
/// repository method that actually failed rather than disappearing into
/// interceptor machinery.
AppException mapDioException(Object error) {
  if (error is! DioException) {
    return UnknownException(error.toString());
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.cancel:
      return const UnknownException('The request was cancelled.');
    case DioExceptionType.badCertificate:
      return const NetworkException('Could not verify a secure connection.');
    case DioExceptionType.badResponse:
      return _mapBadResponse(error);
    case DioExceptionType.unknown:
      return const NetworkException();
  }
}

AppException _mapBadResponse(DioException error) {
  final statusCode = error.response?.statusCode ?? 0;
  final body = error.response?.data;

  // The backend's AppError shape is always {"error_code": "...", "message": "..."}
  // (see app/exceptions.py's register_exception_handlers) — every 4xx/5xx this
  // app receives from its own backend follows this exact shape.
  String? backendMessage;
  String? backendErrorCode;
  if (body is Map<String, dynamic>) {
    final rawMessage = body['message'];
    final rawCode = body['error_code'];
    if (rawMessage is String) backendMessage = rawMessage;
    if (rawCode is String) backendErrorCode = rawCode;
  }

  switch (statusCode) {
    case 401:
      return UnauthorizedException(
          backendMessage ?? 'Your session has ended. Please log in again.');
    case 403:
      return ForbiddenException(
          backendMessage ?? "You don't have access to this.");
    case 404:
      return NotFoundException(backendMessage ?? "We couldn't find that.");
    case 409:
    case 422:
    case 429:
      // 429 (RateLimitedError on the backend) covers things like the OTP
      // resend cooldown and event capacity limits — ValidationException is
      // still the right shape for it since the backend's message already
      // explains the wait/limit; it just isn't a malformed-request error.
      return ValidationException(
        backendMessage ?? 'That request could not be completed.',
        errorCode: backendErrorCode,
      );
    default:
      if (statusCode >= 500) {
        return const ServerException();
      }
      return ValidationException(
        backendMessage ?? 'That request could not be completed.',
        errorCode: backendErrorCode,
      );
  }
}
