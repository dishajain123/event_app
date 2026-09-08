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

/// A cover image placeholder used whenever an event has no cover media yet
/// (Phase 2 doesn't yet have a dedicated "cover image" field distinct from
/// the media gallery — this is the graceful fallback rather than a broken
/// image icon).
class _CoverImage extends StatelessWidget {
  final String? imageUrl;
  const _CoverImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accent, AppColors.accentStrong],
          ),
        ),
        child: const Center(
          child: Icon(Icons.event_rounded, color: Colors.white, size: 40),
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

/// The large, cover-led card used in the Home carousel (Section 5.4).
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
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CoverImage(imageUrl: coverImageUrl),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75)
                    ],
                    stops: const [0.4, 1.0],
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          event.displayCategory!,
                          style: AppTypography.caption.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    Text(
                      event.name,
                      style: AppTypography.title.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateRange(
                          event.startDate, event.endDate, event.isSameDayEvent),
                      style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The compact list-row card used in search results and any other flat
/// list of events (Section 5.4).
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _CoverImage(imageUrl: coverImageUrl),
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
                  Text(
                    _formatDateRange(
                        event.startDate, event.endDate, event.isSameDayEvent),
                    style: AppTypography.caption,
                  ),
                  if (event.displayCategory != null) ...[
                    const SizedBox(height: 4),
                    Text(event.displayCategory!,
                        style: AppTypography.captionSubtle),
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
