import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Type scale — refined for a "premium product" feel while staying on the
/// system font stack (no font asset is bundled in this project, so nothing
/// here references one). Every style that existed before
/// ([display], [headline], [title], [bodyStrong], [body], [bodyMuted],
/// [caption], [captionSubtle], [button]) keeps its exact name and role, so
/// no call site elsewhere in the app needs to change. New styles
/// ([hero], [statNumber], [overline], [buttonLarge]) are additive, for
/// Phase 2's hero headers, stat rows, and section eyebrows.
class AppTypography {
  AppTypography._();

  /// Splash / hero screens only — bigger and tighter than [display].
  static const hero = TextStyle(
    fontSize: 40,
    height: 46 / 40,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -1.0,
  );

  static const display = TextStyle(
    fontSize: 30,
    height: 38 / 30,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.6,
  );

  static const headline = TextStyle(
    fontSize: 22,
    height: 29 / 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.3,
  );

  static const title = TextStyle(
    fontSize: 17,
    height: 23 / 17,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: -0.1,
  );

  static const bodyStrong = TextStyle(
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const bodyMuted = TextStyle(
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
  );

  static const caption = TextStyle(
    fontSize: 12.5,
    height: 17 / 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.inkMuted,
  );

  static const captionSubtle = TextStyle(
    fontSize: 12.5,
    height: 17 / 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSubtle,
  );

  /// Small caps-style eyebrow label above a section title, e.g. "SCHEDULE".
  static const overline = TextStyle(
    fontSize: 11.5,
    height: 14 / 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.inkSubtle,
    letterSpacing: 1.1,
  );

  /// Large numeral for stat rows / counters (e.g. "128 registered").
  static const statNumber = TextStyle(
    fontSize: 22,
    height: 26 / 22,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.4,
  );

  static const button = TextStyle(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const buttonLarge = TextStyle(
    fontSize: 16,
    height: 21 / 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );
}