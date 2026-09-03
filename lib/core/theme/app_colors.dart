import 'package:flutter/material.dart';

/// Color tokens per the plan's Section 5.1. Deliberately NOT deep magenta —
/// the console's own stated direction was moving away from that toward an
/// indigo/violet accent with glass surfaces, and this shares that DNA
/// rather than inventing a separate mobile palette. `staffModeAccent` is
/// the one deliberate departure: Staff Mode gets its own warm accent so
/// switching modes is instantly recognizable without reading any text.
class AppColors {
  AppColors._();

  static const accent = Color(0xFF6366F1); // indigo-500
  static const accentStrong = Color(0xFF4F46E5); // indigo-600
  static const accentSoft = Color(0xFFEEF0FF);

  /// Staff Mode's distinct identity color — amber-leaning, used only in the
  /// Staff Mode shell's nav bar and app bar (Section 5.1).
  static const staffModeAccent = Color(0xFFD97706);
  static const staffModeAccentSoft = Color(0xFFFFFBEB);

  static const background = Color(0xFFF4F5FB);
  static const backgroundAlt = Color(0xFFEEF0FA);

  static const surface = Color(0xFFFFFFFF);
  static const glassBorder = Color(0x8CFFFFFF);

  static const ink = Color(0xFF1B1D29);
  static const inkMuted = Color(0xFF5B6072);
  static const inkSubtle = Color(0xFF9297AB);

  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFECFDF3);
  static const warning = Color(0xFFD97706);
  static const warningSoft = Color(0xFFFFFBEB);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEF2F2);
  static const info = Color(0xFF0284C7);
  static const infoSoft = Color(0xFFF0F9FF);

  /// The soft radial-gradient-over-off-white background used on every
  /// screen (Section 5.1) — the mobile-scaled recipe of the console's own
  /// ambient background.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEF0FF), Color(0xFFF4F5FB), Color(0xFFF0F9FF)],
  );
}
