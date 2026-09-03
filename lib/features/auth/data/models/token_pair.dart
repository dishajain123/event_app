/// Mirrors `app/modules/identity/schemas.py`'s `OTPRequestOut` exactly.
class OtpRequestResult {
  final String message;
  final int resendAvailableInSeconds;

  const OtpRequestResult({required this.message, required this.resendAvailableInSeconds});

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    return OtpRequestResult(
      message: json['message'] as String,
      resendAvailableInSeconds: json['resend_available_in_seconds'] as int,
    );
  }
}

/// Mirrors `app/modules/identity/schemas.py`'s `TokenPairOut` exactly.
class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({required this.accessToken, required this.refreshToken});

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}
