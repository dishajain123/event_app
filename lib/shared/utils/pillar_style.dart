import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The single source of truth for a pillar's (main category's) visual
/// identity — gradient, solid tint (for tinted shadows), and icon. Derived
/// from the category's *name*, not its position in a list, so it stays
/// correct however the backend orders categories and never drifts between
/// the places that render a pillar: Home's tiles, event cover fallbacks,
/// and the category detail screen all read from here.
class PillarStyle {
  final Gradient gradient;
  final Color solid;
  final IconData icon;
  const PillarStyle(
      {required this.gradient, required this.solid, required this.icon});
}

PillarStyle pillarStyleForCategory(String? name) {
  final normalized = (name ?? '').toLowerCase();
  if (normalized.contains('corporate')) {
    return const PillarStyle(
      gradient: AppColors.pillarCorporate,
      solid: AppColors.pillarCorporateSolid,
      icon: Icons.business_center_rounded,
    );
  }
  if (normalized.contains('community')) {
    return const PillarStyle(
      gradient: AppColors.pillarCommunity,
      solid: AppColors.pillarCommunitySolid,
      icon: Icons.groups_rounded,
    );
  }
  if (normalized.contains('contribute')) {
    return const PillarStyle(
      gradient: AppColors.pillarContribute,
      solid: AppColors.pillarContributeSolid,
      icon: Icons.volunteer_activism_rounded,
    );
  }
  if (normalized.contains('live')) {
    return const PillarStyle(
      gradient: AppColors.pillarLive,
      solid: AppColors.pillarLiveSolid,
      icon: Icons.podcasts_rounded,
    );
  }
  return const PillarStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.accent, AppColors.accentViolet],
    ),
    solid: AppColors.accentStrong,
    icon: Icons.event_rounded,
  );
}

/// Topic/sub-category keyword → icon, shared by event cover fallbacks and
/// the category detail list so the same word ("Sports", "Food", "Blood
/// Donation Camp"…) always draws the same icon everywhere in the app.
const Map<String, IconData> topicIconKeywords = {
  'sport': Icons.sports_soccer_rounded,
  'cricket': Icons.sports_cricket_rounded,
  'football': Icons.sports_soccer_rounded,
  'run': Icons.directions_run_rounded,
  'fitness': Icons.fitness_center_rounded,
  'wellness': Icons.self_improvement_rounded,
  'food': Icons.restaurant_rounded,
  'beverage': Icons.local_bar_rounded,
  'music': Icons.music_note_rounded,
  'cultur': Icons.theater_comedy_rounded,
  'performance': Icons.theater_comedy_rounded,
  'talent': Icons.star_rounded,
  'competition': Icons.emoji_events_rounded,
  'innovation': Icons.lightbulb_rounded,
  'startup': Icons.rocket_launch_rounded,
  'showcase': Icons.storefront_rounded,
  'leadership': Icons.record_voice_over_rounded,
  'talk': Icons.record_voice_over_rounded,
  'business': Icons.business_center_rounded,
  'network': Icons.hub_rounded,
  'blood': Icons.bloodtype_rounded,
  'tree': Icons.park_rounded,
  'plantation': Icons.park_rounded,
  'clean': Icons.cleaning_services_rounded,
  'green': Icons.eco_rounded,
  'education': Icons.school_rounded,
  'give back': Icons.card_giftcard_rounded,
  'social': Icons.volunteer_activism_rounded,
  'ngo': Icons.diversity_1_rounded,
  'family': Icons.family_restroom_rounded,
  'youth': Icons.emoji_people_rounded,
  'fun': Icons.celebration_rounded,
  'entertainment': Icons.celebration_rounded,
  'global': Icons.public_rounded,
  'experience': Icons.public_rounded,
};

/// Looks up [topicIconKeywords] against [topic] first, then [fallbackPillar]
/// (typically the main category name), finally the pillar's own default icon.
IconData iconForTopic(String? topic, {String? fallbackPillar}) {
  final normalizedTopic = (topic ?? '').toLowerCase();
  for (final entry in topicIconKeywords.entries) {
    if (normalizedTopic.contains(entry.key)) return entry.value;
  }
  return pillarStyleForCategory(fallbackPillar).icon;
}
