import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/registrations_providers.dart';
import '../../data/models/registration_status.dart';

class RegistrationDetailScreen extends ConsumerWidget {
  final String registrationId;
  const RegistrationDetailScreen({super.key, required this.registrationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationAsync = ref.watch(registrationDetailProvider(registrationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: SafeArea(
        child: registrationAsync.when(
          loading: () => const AppSkeleton.detailPage(),
          error: (error, stackTrace) => AppErrorState(
            error: error is AppException ? error : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(registrationDetailProvider(registrationId)),
          ),
          data: (registration) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  Text(
                    registration.participationType[0].toUpperCase() + registration.participationType.substring(1),
                    style: AppTypography.headline,
                  ),
                  const Spacer(),
                  StatusBadge(label: registration.status.label),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (registration.rejectionReason != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(registration.rejectionReason!, style: AppTypography.body),
                ),
              const SizedBox(height: AppSpacing.lg),
              if (registration.participants.isNotEmpty) ...[
                Text('Participants', style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                for (final participant in registration.participants)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      participant.isCaptain ? '${participant.fullName} (Captain)' : participant.fullName,
                      style: AppTypography.body,
                    ),
                  ),
              ],
              if (registration.submittedAt != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Submitted ${registration.submittedAt}', style: AppTypography.caption),
              ],
              if (registration.status == RegistrationStatus.pendingPayment) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Pay now',
                  fullWidth: true,
                  size: AppButtonSize.large,
                  onPressed: () => context.push(RoutePaths.paymentCheckoutPath(registration.id)),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Request assistance with this fee',
                  variant: AppButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: () => context.push(
                    RoutePaths.requestAssistancePath(registration.eventId, registration.id),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
