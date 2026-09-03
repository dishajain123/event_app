/// The one typed error hierarchy every repository in the app maps a failure
/// into. Nothing above the repository layer ever sees a raw [DioException]
/// or a bare string — every screen's error UI (Section 3.7) branches on one
/// of these subtypes, never on parsing a message string itself.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// No connection, DNS failure, or the request timed out before a response
/// arrived at all. Maps to Section 3.7's "Error — network" state: retry
/// makes sense here.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'Check your connection and try again.']);
}

/// The backend responded, but with a 401 that survived a refresh attempt
/// (see AuthInterceptor). Maps to Section 3.7's "Unauthorized" state: the
/// session is over, not retryable.
final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Your session has ended. Please log in again.']);
}

/// The backend responded with a 403 — the caller is authenticated but not
/// allowed to do this. Maps to Section 3.7's "Forbidden" state: distinct
/// from Unauthorized on purpose, since retrying or re-logging-in won't help.
final class ForbiddenException extends AppException {
  const ForbiddenException([super.message = "You don't have access to this."]);
}

/// A 404 — the thing being asked for doesn't exist (or doesn't exist for
/// this caller, which the backend deliberately doesn't distinguish from
/// "doesn't exist at all" for anything ownership-scoped).
final class NotFoundException extends AppException {
  const NotFoundException([super.message = "We couldn't find that."]);
}

/// A 409, or a 422/400 that represents a business-rule rejection rather than
/// a malformed request — e.g. the rule engine rejecting a registration, a
/// duplicate registration, capacity reached. [message] is always the
/// backend's own real message (Section 3.7: never a generic failure text
/// when the backend already explained exactly why).
final class ValidationException extends AppException {
  final String? errorCode;
  const ValidationException(super.message, {this.errorCode});
}

/// A 5xx, or any successful-looking response that failed to parse into the
/// shape the app expected.
final class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on our end. Please try again shortly.']);
}

/// A catch-all for anything that doesn't fit the above — kept deliberately
/// rare; reaching this usually means a new backend error shape needs its own
/// case above, not that this case should absorb it silently.
final class UnknownException extends AppException {
  const UnknownException([super.message = 'Something unexpected happened.']);
}
