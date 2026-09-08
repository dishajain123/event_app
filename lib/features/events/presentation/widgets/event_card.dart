import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/app_event.dart';

const _monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime d) =>
    '${_monthAbbreviations[d.month - 1]} ${d.day}';

String _formatDateRange(DateTime start, DateTime end, bool sameDay) {
  if (sameDay) return _formatDate(start);
  return '${_formatDate(start)} – ${_formatDate(end)}';
}

/// The event model has no cover-image field of its own (only the media
/// gallery, from Phase 3 onward, carries real photos) — [coverImageUrl] is
/// left as an optional, caller-supplied override for whenever a screen
/// does have one on hand (e.g. the first gallery image). With none
/// supplied, the fallback is a deterministic gradient + icon derived from
/// the event's own category, never a random/mocked photo, so it stays
/// meaningfully tied to real backend data rather than decorative filler.
const _fallbackGradients = [
  AppColors.pillarCorporate,
  AppColors.pillarCommunity,
  AppColors.pillarContribute,
  AppColors.pillarLive,
];

const _fallbackIcons = [
  Icons.event_rounded,
  Icons.groups_rounded,
  Icons.emoji_events_rounded,
  Icons.celebration_rounded,
  Icons.mic_rounded,
  Icons.sports_soccer_rounded,
];

int _seedFor(String value) => value.codeUnits.fold(0, (a, b) => a + b);

class _CoverImage extends StatelessWidget {
  final String? imageUrl;
  final String seed;

  const _CoverImage({this.imageUrl, required this.seed});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      final s = _seedFor(seed);
      return Container(
        decoration: BoxDecoration(
          gradient: _fallbackGradients[s % _fallbackGradients.length],
        ),
        child: Center(
          child: Icon(_fallbackIcons[s % _fallbackIcons.length],
              color: Colors.white.withValues(alpha: 0.92), size: 40),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: AppColors.backgroundAlt),
      errorWidget: (context, url, error) => Container(
        color: AppColors.backgroundAlt,
        child: const Icon(Icons.image_not_supported_outlined,
            color: AppColors.inkSubtle),
      ),
    );
  }
}

/// The large, cover-led card used in Home's "Upcoming" strip and the
/// featured carousel. Public API is unchanged: [event], [coverImageUrl],
/// [onTap].
class FeaturedEventCard extends StatelessWidget {
  final AppEvent event;
  final String? coverImageUrl;
  final VoidCallback onTap;

  const FeaturedEventCard(
      {super.key,
      required this.event,
      this.coverImageUrl,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: AspectRatio(
          aspectRatio: 4 / 3.4,
          child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CoverImage(imageUrl: coverImageUrl, seed: event.id),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.78)
                      ],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.displayCategory != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            event.displayCategory!,
                            style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      Text(
                        event.name,
                        style:
                            AppTypography.title.copyWith(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.85)),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateRange(event.startDate, event.endDate,
                                event.isSameDayEvent),
                            style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The compact list-row card used in search results and any other flat
/// list of events. Public API is unchanged: [event], [coverImageUrl],
/// [onTap].
class CompactEventCard extends StatelessWidget {
  final AppEvent event;
  final String? coverImageUrl;
  final VoidCallback onTap;

  const CompactEventCard(
      {super.key,
      required this.event,
      this.coverImageUrl,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: _CoverImage(imageUrl: coverImageUrl, seed: event.id),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.name,
                        style: AppTypography.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 12, color: AppColors.inkSubtle),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateRange(event.startDate, event.endDate,
                              event.isSameDayEvent),
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    if (event.displayCategory != null) ...[
                      const SizedBox(height: 4),
                      Text(event.displayCategory!,
                          style: AppTypography.captionSubtle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.inkSubtle),
            ],
          ),
        ),
      ),
    );
  }
}