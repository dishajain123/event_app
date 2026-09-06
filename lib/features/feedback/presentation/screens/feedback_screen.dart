import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/feedback_providers.dart';
import '../../data/models/feedback.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  final String eventId;
  const FeedbackScreen({super.key, required this.eventId});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  String? _categoryCode;
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_categoryCode == null) return;
    setState(() => _submitting = true);
    try {
      await ref.read(feedbackRepositoryProvider).submit(
            eventId: widget.eventId,
            category: _categoryCode!,
            rating: _rating,
            comment: _commentController.text,
          );
      ref.invalidate(eventFeedbackProvider(widget.eventId));
      ref.invalidate(myFeedbackProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Feedback saved.')));
      }
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackAsync = ref.watch(eventFeedbackProvider(widget.eventId));
    final categoriesAsync = ref.watch(feedbackCategoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Give Feedback')),
      body: feedbackAsync.when(
        loading: () => const AppSkeleton.cardList(),
        error: (error, _) => AppErrorState(
          error: error is AppException
              ? error
              : UnknownException(error.toString()),
          onRetry: () => ref.invalidate(eventFeedbackProvider(widget.eventId)),
        ),
        data: (feedback) => categoriesAsync.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, _) => AppErrorState(
            error: error is AppException
                ? error
                : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(feedbackCategoriesProvider),
          ),
          data: (categories) => _buildForm(feedback, categories),
        ),
      ),
    );
  }

  Widget _buildForm(
      List<EventFeedback> feedback, List<FeedbackCategoryOption> categories) {
    if (categories.isEmpty) {
      return const Center(
          child: Text('Feedback categories are not configured.'));
    }
    final selectedCode = _categoryCode ?? categories.first.code;
    _categoryCode ??= selectedCode;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('How was your experience?', style: AppTypography.title),
        const SizedBox(height: AppSpacing.lg),
        DropdownButtonFormField<String>(
          initialValue: selectedCode,
          decoration: const InputDecoration(labelText: 'Category'),
          items: categories
              .map((category) => DropdownMenuItem(
                  value: category.code, child: Text(category.label)))
              .toList(),
          onChanged: (value) => setState(() => _categoryCode = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Rating', style: AppTypography.bodyStrong),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(5, (index) {
            final value = index + 1;
            return IconButton(
              tooltip: '$value star${value == 1 ? '' : 's'}',
              onPressed: () => setState(() => _rating = value),
              icon: Icon(value <= _rating ? Icons.star : Icons.star_border,
                  size: 32),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _commentController,
          maxLines: 4,
          maxLength: 2000,
          decoration: const InputDecoration(
              labelText: 'Comment (optional)', alignLabelWithHint: true),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
            label: 'Save feedback',
            onPressed: _submit,
            loading: _submitting,
            fullWidth: true),
        const SizedBox(height: AppSpacing.xxl),
        Text('Your previous feedback', style: AppTypography.title),
        const SizedBox(height: AppSpacing.md),
        if (feedback.isEmpty)
          Text('You have not submitted feedback for this event yet.',
              style: AppTypography.bodyMuted)
        else
          ...feedback.map((item) => _FeedbackCard(feedback: item)),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final EventFeedback feedback;
  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(feedback.categoryLabel, style: AppTypography.bodyStrong),
          Text('${feedback.rating}/5', style: AppTypography.caption),
          if (feedback.comment?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(feedback.comment!, style: AppTypography.body),
          ],
        ]),
      ),
    );
  }
}
