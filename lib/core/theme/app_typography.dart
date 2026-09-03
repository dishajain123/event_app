import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Type scale per Section 5.2 — tuned for one-handed mobile reading, not a
/// straight port of the console's desktop scale. No custom font is bundled
/// yet (Phase 1 has no sourced font files — see pubspec.yaml's note); every
/// style below falls back to the platform default family until one is
/// added, so nothing here references a font asset that doesn't exist.
class AppTypography {
  AppTypography._();

  static const display = TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.5,
  );

  static const headline = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const title = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const bodyStrong = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const bodyMuted = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
  );

  static const caption = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMuted,
  );

  static const captionSubtle = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSubtle,
  );

  static const button = TextStyle(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}
