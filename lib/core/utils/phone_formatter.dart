/// Mirrors `app/modules/identity/phone.py`'s `normalize_mobile_number`
/// exactly — same accepted input shapes, same rejected cases, same output
/// format. The backend re-normalizes and re-validates on every request
/// regardless (it never trusts a client to have done this correctly), but
/// matching it client-side means a typed-in number that's about to be
/// rejected is caught immediately in the form, not after a round trip.
///
/// If the backend's normalization logic ever changes, this file is the one
/// place to update to match it — never re-derive the rules from scratch
/// here, always re-read the backend source first.
library;

const _defaultCountryCode = '91';

class InvalidMobileNumberException implements Exception {
  final String message;
  const InvalidMobileNumberException(this.message);

  @override
  String toString() => message;
}

/// Throws [InvalidMobileNumberException] with the same messages the
/// backend uses, on exactly the same invalid-input cases.
String normalizeMobileNumber(String value) {
  final cleaned = value.trim();
  if (cleaned.isEmpty) {
    throw const InvalidMobileNumberException('mobile_number is required');
  }

  final hasPlus = cleaned.startsWith('+');
  final digits = cleaned.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    throw const InvalidMobileNumberException('mobile_number must contain digits');
  }

  if (hasPlus) {
    if (digits.length == 12 && digits.startsWith(_defaultCountryCode)) {
      return '+$digits';
    }
    throw const InvalidMobileNumberException('Enter a valid Indian mobile number.');
  }

  if (digits.length == 10) {
    return '+$_defaultCountryCode$digits';
  }

  if (digits.length == 11 && digits.startsWith('0')) {
    return '+$_defaultCountryCode${digits.substring(1)}';
  }

  if (digits.length == 12 && digits.startsWith(_defaultCountryCode)) {
    return '+$digits';
  }

  throw const InvalidMobileNumberException('Enter a valid Indian mobile number.');
}

/// Non-throwing variant for live validation as the user types (e.g.
/// enabling/disabling a submit button) — returns null instead of throwing.
String? tryNormalizeMobileNumber(String value) {
  try {
    return normalizeMobileNumber(value);
  } on InvalidMobileNumberException {
    return null;
  }
}

/// A light display formatter for showing an already-normalized
/// +91XXXXXXXXXX number back to the user more readably, e.g. in the OTP
/// screen's "Sent to +91 98765 43210" caption. Purely cosmetic — never used
/// for anything sent back to the backend, which always gets the raw
/// normalized form.
String formatMobileNumberForDisplay(String normalized) {
  if (!normalized.startsWith('+91') || normalized.length != 13) {
    return normalized;
  }
  final national = normalized.substring(3);
  return '+91 ${national.substring(0, 5)} ${national.substring(5)}';
}
