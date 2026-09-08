/// Spacing scale (4px base unit). Every existing token keeps its exact
/// name and value — [xs]..[xxxl] are unchanged — so nothing that already
/// references [AppSpacing] needs to change. [xxxxl] is additive, for
/// Phase 2's larger hero/section gaps.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
  static const xxxxl = 64.0;
}

/// Radius tokens. [card], [sheet], [pill] are unchanged values. [input]
/// moved from 12 → 14 as part of the visual refresh (slightly rounder
/// fields); every input already goes through [AppTextField], so this is a
/// one-line change that reaches every form automatically. [button] and
/// [chip] are new, additive tokens for the refreshed button/chip widgets.
class AppRadius {
  AppRadius._();

  static const button = 16.0;
  static const chip = 999.0;
  static const input = 14.0;
  static const card = 22.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}