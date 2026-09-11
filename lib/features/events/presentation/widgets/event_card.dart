import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/utils/pillar_style.dart';
import '../../../../shared/widgets/misc/pressable.dart';
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

/// The cover image is [AppEvent.imageUrl] — the optional image uploaded in
/// the Console, stored via the backend media architecture. [coverImageUrl]
/// stays as an optional caller-supplied override (e.g. a gallery image a
/// screen already has on hand). When neither is present, the fallback is a
/// gradient + icon derived from the event's *category* — so it reads as a
/// deliberate category badge, not random filler — and it also covers the
/// loading and failed-image states.
Gradient eventCoverGradient(AppEvent event) {
  return pillarStyleForCategory(event.mainCategory?.name ?? event.category)
      .gradient;
}

IconData eventCoverIcon(AppEvent event) {
  return iconForTopic(
    event.subCategory?.name,
    fallbackPillar: event.mainCategory?.name ?? event.category,
  );
}

class _CoverImage extends StatelessWidget {
  final String? imageUrl;
  final AppEvent event;
  final double iconSize;

  const _CoverImage({this.imageUrl, required this.event, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _GradientFallback(event: event, iconSize: iconSize);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: AppColors.backgroundAlt),
      errorWidget: (context, url, error) =>
          _GradientFallback(event: event, iconSize: iconSize),
    );
  }
}

/// The no-image cover: a category gradient carrying an oversized,
/// low-opacity icon bled off the top-right corner (a watermark, not a
/// centerpiece) plus a soft top-left sheen — reads as a deliberately
/// designed surface instead of "an icon in an empty box".
class _GradientFallback extends StatelessWidget {
  final AppEvent event;
  final double iconSize;
  const _GradientFallback({required this.event, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    final compact = iconSize <= 30;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: eventCoverGradient(event)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!compact)
            Positioned(
              right: -iconSize * 0.55,
              top: -iconSize * 0.55,
              child: Icon(eventCoverIcon(event),
                  color: Colors.white.withValues(alpha: 0.18),
                  size: iconSize * 2.6),
            ),
          if (compact)
            Align(
              alignment: Alignment.center,
              child: Icon(eventCoverIcon(event),
                  color: Colors.white.withValues(alpha: 0.95), size: iconSize),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
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
    return Pressable(
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
                _CoverImage(
                    imageUrl: coverImageUrl ?? event.imageUrl,
                    event: event,
                    iconSize: 46),
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
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: const Color(0x0A000000)),
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
                child: _CoverImage(
                    imageUrl: coverImageUrl ?? event.imageUrl,
                    event: event,
                    iconSize: 26),
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
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkSubtle),
          ],
        ),
      ),
    );
  }
}
