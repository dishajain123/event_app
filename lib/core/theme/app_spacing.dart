/// Spacing scale (4px base unit) and radius tokens per Section 5.3 —
/// rounder absolute values than the console's desktop tokens on purpose,
/// which reads as more native to iOS/Android than importing the web's
/// exact numbers would.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

class AppRadius {
  AppRadius._();

  static const input = 12.0;
  static const card = 20.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}
