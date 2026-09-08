import 'package:flutter/material.dart';

/// GO-360° color system.
///
/// `accent` stays exactly where it was (indigo-500) so every existing
/// reference to [AppColors.accent] / [AppColors.accentStrong] keeps working
/// unchanged — nothing that already reads these tokens needs to change.
/// What's new here is layered on top: a brand gradient (matching the
/// blue → violet → magenta wordmark in the reference direction), four
/// "pillar" gradients for Corporate / Community / Contribute / LIVE
/// (consumed by category/section widgets from Phase 2 onward), and a small
/// set of elevation/glass tokens the refreshed shared widgets use.
class AppColors {
  AppColors._();

  // ---- Core brand (unchanged values, kept stable on purpose) ----
  static const accent = Color(0xFF6366F1); // indigo-500
  static const accentStrong = Color(0xFF4F46E5); // indigo-600
  static const accentSoft = Color(0xFFEEF0FF);

  /// Second brand hue — the violet the wordmark gradient runs into. Used
  /// alongside [accent] for the brand gradient and for glow/highlight
  /// accents; never introduced as a *replacement* for [accent].
  static const accentViolet = Color(0xFF8B5CF6);
  static const accentMagenta = Color(0xFFD946EF);

  static const staffModeAccent = Color(0xFFD97706);
  static const staffModeAccentSoft = Color(0xFFFFFBEB);

  static const background = Color(0xFFF6F6FC);
  static const backgroundAlt = Color(0xFFEEF0FA);

  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF8F9FE);
  static const glassBorder = Color(0x8CFFFFFF);

  static const ink = Color(0xFF14162B);
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

  /// Ambient screen background — softer and slightly cooler than the old
  /// version so gradient pillar cards (below) have room to be the most
  /// saturated thing on any given screen.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF1F1FE), Color(0xFFF7F7FC), Color(0xFFF0F8FC)],
  );

  /// The brand wordmark gradient (blue → violet → magenta), used sparingly:
  /// hero headlines, the primary CTA, the launch/splash mark.
  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFFD946EF)],
  );

  /// Deeper variant of [brandGradient] for large filled surfaces (buttons,
  /// FAB, splash background) where flat brand colors would look washed out.
  static const brandGradientStrong = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4338CA), Color(0xFF6D28D9), Color(0xFFC026D3)],
  );

  // ---- Pillar identity gradients ----
  // One fixed gradient per program pillar. These are additive tokens for
  // Phase 2 (category/pillar cards, chips, section accents) — nothing
  // existing reads them yet, so introducing them here changes no behavior.
  static const pillarCorporate = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  );
  static const pillarCommunity = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
  );
  static const pillarContribute = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF047857)],
  );
  static const pillarLive = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
  );

  static const pillarCorporateSolid = Color(0xFF2563EB);
  static const pillarCommunitySolid = Color(0xFFDB2777);
  static const pillarContributeSolid = Color(0xFF059669);
  static const pillarLiveSolid = Color(0xFFD97706);

  // ---- Elevation / glass tokens for the refreshed shared widgets ----
  static const shadowColor = Color(0x1A1B1D3D);
  static const shadowColorStrong = Color(0x332B2170);

  static Color glassFill({double opacity = 0.72}) =>
      Colors.white.withValues(alpha: opacity);
}