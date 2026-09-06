import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/feedback_providers.dart';
import '../../data/models/feedback.dart';

class MyFeedbackScreen extends ConsumerWidget {
  const MyFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(myFeedbackProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Feedback')),
      body: feedbackAsync.when(
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
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _MyFeedbackCard(feedback: feedback[index]),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(feedback.eventName ?? 'Event', style: AppTypography.bodyStrong),
          const SizedBox(height: 4),
          Text(feedback.categoryLabel, style: AppTypography.caption),
          Text('${feedback.rating}/5', style: AppTypography.caption),
          if (feedback.comment?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(feedback.comment!, style: AppTypography.body),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(_formatDate(feedback.createdAt),
              style: AppTypography.captionSubtle),
        ]),
      ),
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';
}
