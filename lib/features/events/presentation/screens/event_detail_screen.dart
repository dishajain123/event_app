import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../media/application/media_providers.dart';
import '../../application/events_providers.dart';
import '../../data/models/app_event.dart';
import '../../data/models/event_status.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      body: eventAsync.when(
        loading: () => const SafeArea(child: AppSkeleton.detailPage()),
        error: (error, stackTrace) => SafeArea(
          child: Column(
            children: [
              const _BackBar(),
              Expanded(
                child: AppErrorState(
                  error: error is AppException ? error : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
                ),
              ),
            ],
          ),
        ),
        data: (event) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppColors.background,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentStrong],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.event_rounded, color: Colors.white, size: 56),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(label: event.status.label, tone: _statusTone(event.status)),
                        if (event.displayCategory != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          StatusBadge(label: event.displayCategory!, tone: StatusTone.accent),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(event.name, style: AppTypography.display),
                    const SizedBox(height: AppSpacing.sm),
                    _DateRow(event: event),
                    if (event.organizer != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Organized by ${event.organizer!.name ?? event.organizer!.mobileNumber}',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                    if (event.description != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(event.description!, style: AppTypography.body),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                    if (event.status.acceptsRegistration)
                      AppButton(
                        label: 'Register',
                        fullWidth: true,
                        size: AppButtonSize.large,
                        onPressed: () => context.push(RoutePaths.participationTypeSelectorPath(event.id)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _registrationClosedMessage(event.status),
                          style: AppTypography.bodyMuted,
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xxl),
                    _QuickActionsRow(eventId: eventId),
                    const SizedBox(height: AppSpacing.xl),
                    _VenuesSection(eventId: eventId),
                    const SizedBox(height: AppSpacing.xl),
                    _ScheduleSection(eventId: eventId),
                    const SizedBox(height: AppSpacing.xl),
                    _SponsorsSection(eventId: eventId),
                    const SizedBox(height: AppSpacing.xl),
                    _MediaSection(eventId: eventId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatusTone _statusTone(EventStatus status) => switch (status) {
        EventStatus.draft => StatusTone.neutral,
        EventStatus.configured => StatusTone.info,
        EventStatus.published => StatusTone.accent,
        EventStatus.registrationOpen => StatusTone.success,
        EventStatus.registrationClosed => StatusTone.warning,
        EventStatus.live => StatusTone.success,
        EventStatus.completed => StatusTone.neutral,
        EventStatus.archived => StatusTone.neutral,
      };

  String _registrationClosedMessage(EventStatus status) => switch (status) {
        EventStatus.registrationClosed => 'Registration has closed for this event.',
        EventStatus.live => 'This event is currently live.',
        EventStatus.completed => 'This event has ended.',
        EventStatus.archived => 'This event is archived.',
        _ => 'Registration isn\'t open for this event yet.',
      };
}

class _QuickActionsRow extends StatelessWidget {
  final String eventId;
  const _QuickActionsRow({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionChip(
            icon: Icons.card_giftcard_rounded,
            label: 'Refer & Earn',
            onTap: () => context.push(RoutePaths.referralPath(eventId)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: () => context.push(RoutePaths.mediaGalleryPath(eventId)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.emoji_events_outlined,
            label: 'Competition',
            onTap: () => context.push(RoutePaths.competitionStagesPath(eventId)),
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentStrong, size: 20),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.captionSubtle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final AppEvent event;
  const _DateRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.inkSubtle),
        const SizedBox(width: 6),
        Text(_formatFullDateRange(event.startDate, event.endDate), style: AppTypography.bodyMuted),
      ],
    );
  }
}

String _formatFullDateRange(DateTime start, DateTime end) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  String fmt(DateTime d) => '${months[d.month - 1]} ${d.day}, ${d.year}';
  final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
  return sameDay ? fmt(start) : '${fmt(start)} – ${fmt(end)}';
}

class _VenuesSection extends ConsumerWidget {
  final String eventId;
  const _VenuesSection({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(eventVenuesProvider(eventId));
    return venuesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (venues) {
        if (venues.isEmpty) return const SizedBox.shrink();
        return _Section(
          title: 'Venue',
          child: Column(
            children: [
              for (final venue in venues)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: AppColors.inkSubtle),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(venue.name, style: AppTypography.bodyStrong),
                            if (venue.address != null) Text(venue.address!, style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleSection extends ConsumerWidget {
  final String eventId;
  const _ScheduleSection({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(eventScheduleProvider(eventId));
    return scheduleAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final sorted = [...items]..sort((a, b) => a.startTime.compareTo(b.startTime));
        return _Section(
          title: 'Schedule',
          child: Column(
            children: [
              for (final item in sorted)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(
                          '${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')}',
                          style: AppTypography.caption,
                        ),
                      ),
                      Expanded(child: Text(item.title, style: AppTypography.body)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SponsorsSection extends ConsumerWidget {
  final String eventId;
  const _SponsorsSection({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorsAsync = ref.watch(eventSponsorsProvider(eventId));
    return sponsorsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (sponsors) {
        if (sponsors.isEmpty) return const SizedBox.shrink();
        return _Section(
          title: 'Sponsors',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final sponsor in sponsors)
                Chip(label: Text(sponsor.name), backgroundColor: AppColors.accentSoft),
            ],
          ),
        );
      },
    );
  }
}

class _MediaSection extends ConsumerWidget {
  final String eventId;
  const _MediaSection({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(eventMediaProvider(eventId));
    return mediaAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (mediaItems) {
        if (mediaItems.isEmpty) return const SizedBox.shrink();
        return _Section(
          title: 'Gallery',
          child: SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mediaItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = mediaItems[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    item.publicUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 96,
                      height: 96,
                      color: AppColors.backgroundAlt,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.inkSubtle),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}
