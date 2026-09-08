import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/feedback_providers.dart';
import '../../data/models/feedback.dart';

/// Provider watched is unchanged from before — only the card presentation
/// was refreshed.
class MyFeedbackScreen extends ConsumerWidget {
  const MyFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(myFeedbackProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Feedback')),
      body: AppBackground(
        child: feedbackAsync.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, _) => AppErrorState(
            error: error is AppException
                ? error
                : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(myFeedbackProvider),
          ),
          data: (feedback) => feedback.isEmpty
              ? const AppEmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'No feedback yet',
                  description: 'Your event feedback will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(myFeedbackProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: feedback.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        _MyFeedbackCard(feedback: feedback[index]),
                  ),
                ),
        ),
      ),
    );
  }
}

class _MyFeedbackCard extends StatelessWidget {
  final EventFeedback feedback;
  const _MyFeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(feedback.eventName ?? 'Event',
                    style: AppTypography.bodyStrong),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < feedback.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 14,
                    color: index < feedback.rating
                        ? const Color(0xFFF59E0B)
                        : AppColors.inkSubtle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(feedback.categoryLabel, style: AppTypography.caption),
          if (feedback.comment?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(feedback.comment!, style: AppTypography.body),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(_formatDate(feedback.createdAt),
              style: AppTypography.captionSubtle),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';
}