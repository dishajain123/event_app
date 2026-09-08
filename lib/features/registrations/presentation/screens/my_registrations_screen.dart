import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/registrations_providers.dart';
import '../../data/models/registration.dart';
import '../../data/models/registration_status.dart';

const _statusTones = {
  RegistrationStatus.started: StatusTone.neutral,
  RegistrationStatus.submitted: StatusTone.info,
  RegistrationStatus.pendingVerification: StatusTone.warning,
  RegistrationStatus.pendingPayment: StatusTone.warning,
  RegistrationStatus.refundPending: StatusTone.warning,
  RegistrationStatus.refundFailed: StatusTone.danger,
  RegistrationStatus.approved: StatusTone.accent,
  RegistrationStatus.confirmed: StatusTone.success,
  RegistrationStatus.checkedIn: StatusTone.success,
  RegistrationStatus.completed: StatusTone.success,
  RegistrationStatus.rejected: StatusTone.danger,
  RegistrationStatus.cancelled: StatusTone.neutral,
};

class MyRegistrationsScreen extends ConsumerWidget {
  const MyRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationsAsync = ref.watch(myRegistrationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Registrations')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myRegistrationsProvider),
          child: registrationsAsync.when(
            loading: () => const AppSkeleton.cardList(),
            error: (error, stackTrace) => ListView(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myRegistrationsProvider),
                ),
              ],
            ),
            data: (registrations) {
              if (registrations.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: AppSpacing.xxxl),
                    AppEmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No registrations yet',
                      description:
                          'Register for an event from the Home tab to see it here.',
                    ),
                  ],
                );
              }
              final sorted = [...registrations]
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: sorted.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _RegistrationCard(registration: sorted[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final AppRegistration registration;
  const _RegistrationCard({required this.registration});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () =>
          context.push(RoutePaths.registrationDetailPath(registration.id)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: AppColors.accentSoft, shape: BoxShape.circle),
            child: const Icon(Icons.assignment_outlined,
                color: AppColors.accentStrong, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registration.participationType[0].toUpperCase() +
                      registration.participationType.substring(1),
                  style: AppTypography.bodyStrong,
                ),
                const SizedBox(height: 4),
                Text(
                  'Registered ${registration.createdAt.day}/${registration.createdAt.month}/${registration.createdAt.year}',
                  style: AppTypography.caption,
                ),
                if (registration.rejectionReason != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    registration.rejectionReason!,
                    style: AppTypography.captionSubtle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: registration.status.label,
            tone: _statusTones[registration.status] ?? StatusTone.neutral,
          ),
        ],
      ),
    );
  }
}