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
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../application/registrations_providers.dart';
import '../../data/models/registration.dart';
import '../../data/models/registration_status.dart';
import '../../../tickets/application/tickets_providers.dart';

/// The provider watched, every route pushed, [_canShowCancel]'s eligible
/// set, and [_cancel]'s repository call are all unchanged from before —
/// this file only restyles the presentation.
class RegistrationDetailScreen extends ConsumerWidget {
  final String registrationId;
  const RegistrationDetailScreen({super.key, required this.registrationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationAsync =
        ref.watch(registrationDetailProvider(registrationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: AppBackground(
        child: SafeArea(
          child: registrationAsync.when(
            loading: () => const AppSkeleton.detailPage(),
            error: (error, stackTrace) => AppErrorState(
              error: error is AppException
                  ? error
                  : UnknownException(error.toString()),
              onRetry: () =>
                  ref.invalidate(registrationDetailProvider(registrationId)),
            ),
            data: (registration) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              registration.participationType[0]
                                      .toUpperCase() +
                                  registration.participationType.substring(1),
                              style: AppTypography.headline,
                            ),
                          ),
                          StatusBadge(label: registration.status.label),
                        ],
                      ),
                      if (registration.submittedAt != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text('Submitted ${registration.submittedAt}',
                            style: AppTypography.caption),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (registration.rejectionReason != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 18, color: AppColors.danger),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(registration.rejectionReason!,
                              style: AppTypography.body
                                  .copyWith(color: AppColors.danger)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (registration.participants.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Participants', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.md),
                        for (final participant in registration.participants)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              children: [
                                const Icon(Icons.person_rounded,
                                    size: 16, color: AppColors.inkSubtle),
                                const SizedBox(width: 6),
                                Text(
                                  participant.isCaptain
                                      ? '${participant.fullName} (Captain)'
                                      : participant.fullName,
                                  style: AppTypography.body,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (registration.status == RegistrationStatus.pendingPayment) ...[
                  AppButton(
                    label: 'Pay now',
                    fullWidth: true,
                    size: AppButtonSize.large,
                    onPressed: () => context
                        .push(RoutePaths.paymentCheckoutPath(registration.id)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Request assistance with this fee',
                    variant: AppButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => context.push(
                      RoutePaths.requestAssistancePath(
                          registration.eventId, registration.id),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (registration.cancellationReason != null) ...[
                  Text('Cancellation note: ${registration.cancellationReason}',
                      style: AppTypography.bodyMuted),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (registration.paymentStatus != null) ...[
                  Text(
                    'Payment: ${registration.paymentStatus!.replaceAll('_', ' ')}',
                    style: AppTypography.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (registration.refundStatus != null) ...[
                  Text(
                    'Refund: ${registration.refundStatus!.replaceAll('_', ' ')}',
                    style: AppTypography.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (_canShowCancel(registration)) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Cancel registration',
                    fullWidth: true,
                    variant: AppButtonVariant.danger,
                    onPressed: () => _cancel(context, ref, registration.id),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canShowCancel(AppRegistration registration) {
    const eligible = {
      RegistrationStatus.started,
      RegistrationStatus.submitted,
      RegistrationStatus.pendingVerification,
      RegistrationStatus.pendingPayment,
      RegistrationStatus.approved,
      RegistrationStatus.confirmed,
      RegistrationStatus.refundFailed,
    };
    if (!eligible.contains(registration.status)) return false;
    final deadline = registration.cancellationDeadlineAt;
    return deadline == null || DateTime.now().isBefore(deadline);
  }

  Future<void> _cancel(
      BuildContext context, WidgetRef ref, String registrationId) async {
    final confirmed = await showConfirmActionSheet(
      context,
      title: 'Cancel this registration?',
      description:
          'Paid registrations enter refund review. Your ticket is cancelled only after a full refund succeeds.',
      confirmLabel: 'Cancel registration',
      danger: true,
      requireReason: true,
      reasonLabel: 'Reason for cancellation',
      onConfirm: (reason) async {
        await ref.read(cancelRegistrationProvider)(registrationId,
            reason: reason);
        ref.invalidate(registrationDetailProvider(registrationId));
        ref.invalidate(myRegistrationsProvider);
        ref.invalidate(myTicketsProvider);
      },
    );
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cancellation status updated.')),
      );
    }
  }
}