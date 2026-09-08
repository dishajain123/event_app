import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../application/assistance_providers.dart';
import '../../data/models/assistance_request.dart';

const _statusTones = {
  AssistanceRequestStatus.pending: StatusTone.warning,
  AssistanceRequestStatus.assigned: StatusTone.info,
  AssistanceRequestStatus.approved: StatusTone.success,
  AssistanceRequestStatus.rejected: StatusTone.danger,
};

/// Provider watched is unchanged from before — only the row presentation
/// (now [AppCard]) was refreshed.
class MyAssistanceRequestsScreen extends ConsumerWidget {
  const MyAssistanceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myAssistanceRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assistance Requests')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myAssistanceRequestsProvider),
          child: requestsAsync.when(
            loading: () => const AppSkeleton.cardList(),
            error: (error, stackTrace) => ListView(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myAssistanceRequestsProvider),
                ),
              ],
            ),
            data: (requests) {
              if (requests.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: AppSpacing.xxxl),
                    AppEmptyState(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'No assistance requests',
                      description:
                          'A fee-waiver request you submit shows up here with its status.',
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: requests.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                  color: AppColors.accentSoft,
                                  shape: BoxShape.circle),
                              child: const Icon(
                                  Icons.volunteer_activism_rounded,
                                  color: AppColors.accentStrong,
                                  size: 18),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                request.reason,
                                style: AppTypography.bodyStrong,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge(
                              label: request.status.label,
                              tone: _statusTones[request.status] ??
                                  StatusTone.neutral,
                            ),
                          ],
                        ),
                        if (request.decisionReason != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(request.decisionReason!,
                              style: AppTypography.captionSubtle),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}