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
import '../../data/models/event_configuration_summary.dart';
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
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
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
                    child: Icon(Icons.event_rounded,
                        color: Colors.white, size: 56),
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
                        StatusBadge(
                            label: event.status.label,
                            tone: _statusTone(event.status)),
                        if (event.displayCategory != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          StatusBadge(
                              label: event.displayCategory!,
                              tone: StatusTone.accent),
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
                    if (event.configuration != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _RegistrationCapacitySummary(
                          configuration: event.configuration!),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    if (event.status.acceptsRegistration &&
                        event.configuration?.registrationStatus == 'full')
                      AppButton(
                        label: 'Join Waitlist',
                        fullWidth: true,
                        size: AppButtonSize.large,
                        icon: Icons.queue_outlined,
                        onPressed: () =>
                            context.push(RoutePaths.waitlistJoinPath(event.id)),
                      )
                    else if (event.status.acceptsRegistration &&
                        event.configuration?.registrationStatus != 'closed')
                      AppButton(
                        label: 'Register',
                        fullWidth: true,
                        size: AppButtonSize.large,
                        onPressed: () => context.push(
                            RoutePaths.participationTypeSelectorPath(event.id)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _registrationClosedMessage(
                              event.status, event.configuration),
                          style: AppTypography.bodyMuted,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (event.status == EventStatus.live ||
                        event.status == EventStatus.completed ||
                        event.status == EventStatus.archived) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Give Feedback',
                        variant: AppButtonVariant.secondary,
                        fullWidth: true,
                        icon: Icons.rate_review_outlined,
                        onPressed: () => context
                            .push(RoutePaths.eventFeedbackPath(event.id)),
                      ),
                    ],
                    if (event.status == EventStatus.live ||
                        event.status == EventStatus.completed) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Live polls & Q&A',
                        variant: AppButtonVariant.secondary,
                        fullWidth: true,
                        icon: Icons.question_answer_outlined,
                        onPressed: () => context
                            .push(RoutePaths.eventInteractionsPath(event.id)),
                      ),
                    ],
                    if (event.status == EventStatus.live) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Participant networking',
                        variant: AppButtonVariant.secondary,
                        fullWidth: true,
                        icon: Icons.people_alt_outlined,
                        onPressed: () => context.push(
                          RoutePaths.eventNetworkingPath(event.id),
                        ),
                      ),
                    ],
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

  String _registrationClosedMessage(
      EventStatus status, EventConfigurationSummary? configuration) {
    if (configuration?.registrationStatus == 'full') {
      return 'Registration is full for this event.';
    }
    if (configuration?.registrationStatus == 'closed') {
      return 'Registration has closed for this event.';
    }
    return switch (status) {
      EventStatus.registrationClosed =>
        'Registration has closed for this event.',
      EventStatus.live => 'This event is currently live.',
      EventStatus.completed => 'This event has ended.',
      EventStatus.archived => 'This event is archived.',
      _ => 'Registration isn\'t open for this event yet.',
    };
  }
}

class _RegistrationCapacitySummary extends StatelessWidget {
  final EventConfigurationSummary configuration;

  const _RegistrationCapacitySummary({required this.configuration});

  @override
  Widget build(BuildContext context) {
    final hasCapacity = configuration.capacity != null;
    final isLimited = configuration.registrationStatus == 'limited';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isLimited ? AppColors.warningSoft : AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCapacity)
            Text(
              '${configuration.registeredCount} registered${configuration.availableCapacity != null ? ' · ${configuration.availableCapacity} seats available' : ''} of ${configuration.capacity}',
              style: AppTypography.bodyStrong,
            ),
          if (!hasCapacity)
            Text('${configuration.registeredCount} registered',
                style: AppTypography.bodyStrong),
          if (configuration.registrationEndAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Registration closes ${_formatFullDateTime(configuration.registrationEndAt!)}',
              style: AppTypography.bodyMuted,
            ),
          ],
          if (isLimited) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text('Limited seats available — Register now!',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
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
            onTap: () =>
                context.push(RoutePaths.competitionStagesPath(eventId)),
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
  const _QuickActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentStrong, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: AppTypography.captionSubtle,
                textAlign: TextAlign.center),
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
        const Icon(Icons.calendar_today_rounded,
            size: 16, color: AppColors.inkSubtle),
        const SizedBox(width: 6),
        Text(_formatFullDateRange(event.startDate, event.endDate),
            style: AppTypography.bodyMuted),
      ],
    );
  }
}

String _formatFullDateRange(DateTime start, DateTime end) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  String fmt(DateTime d) => '${months[d.month - 1]} ${d.day}, ${d.year}';
  final sameDay = start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  return sameDay ? fmt(start) : '${fmt(start)} – ${fmt(end)}';
}

String _formatFullDateTime(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
          ? value.hour - 12
          : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${_formatFullDateRange(value, value)} at $hour:$minute $period';
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
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.inkSubtle),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(venue.name, style: AppTypography.bodyStrong),
                            if (venue.address != null)
                              Text(venue.address!,
                                  style: AppTypography.caption),
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
        final sorted = [...items]
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
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
                      Expanded(
                          child: Text(item.title, style: AppTypography.body)),
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
                Card(
                  child: ListTile(
                    leading: sponsor.logoUrl == null
                        ? const Icon(Icons.handshake_outlined)
                        : Image.network(sponsor.logoUrl!,
                            width: 44, height: 44, fit: BoxFit.contain),
                    title: Text(sponsor.name),
                    subtitle: Text(
                      [
                        sponsor.category,
                        sponsor.description ?? sponsor.offerDetails
                      ].whereType<String>().join(' · '),
                    ),
                  ),
                ),
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
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppColors.inkSubtle),
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
