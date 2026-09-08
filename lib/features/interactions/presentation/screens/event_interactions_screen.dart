import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../auth/application/auth_state_provider.dart';
import '../../application/interactions_providers.dart';
import '../../data/models/interaction.dart';

/// Every provider watched and every `interactionsRepositoryProvider` call
/// (vote/results/upvote/ask) is unchanged from before, including
/// [_requireAuthentication]'s exact redirect-with-returnTo behavior. Only
/// the presentation was refreshed.
class EventInteractionsScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventInteractionsScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventInteractionsScreen> createState() =>
      _EventInteractionsScreenState();
}

class _EventInteractionsScreenState
    extends ConsumerState<EventInteractionsScreen> {
  final selected = <String>{};

  bool _requireAuthentication() {
    if (ref.read(authStateProvider) is AuthAuthenticated) return true;
    context.push(Uri(path: RoutePaths.mobileNumber, queryParameters: {
      'returnTo': RoutePaths.eventInteractionsPath(widget.eventId),
    }).toString());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final polls = ref.watch(eventPollsProvider(widget.eventId));
    final questions = ref.watch(eventQuestionsProvider(widget.eventId));
    return Scaffold(
      appBar: AppBar(title: const Text('Live Interactions')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(eventPollsProvider(widget.eventId));
            ref.invalidate(eventQuestionsProvider(widget.eventId));
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const Text('Live polls', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              _polls(polls),
              const SizedBox(height: AppSpacing.xl),
              const Text('Questions', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              _questions(questions),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Ask a question',
                icon: Icons.question_answer_outlined,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: _askQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _polls(AsyncValue<List<EventPoll>> state) => state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Unable to load polls: $error',
            style: AppTypography.bodyMuted),
        data: (items) => items.isEmpty
            ? const Text('No live polls right now.', style: AppTypography.bodyMuted)
            : Column(children: items.map(_pollCard).toList()),
      );

  Widget _pollCard(EventPoll poll) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child:
                          Text(poll.title, style: AppTypography.bodyStrong)),
                  StatusBadge(
                    label: poll.status,
                    tone: poll.status == 'live'
                        ? StatusTone.success
                        : StatusTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final option in poll.options)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selected.contains(option.id),
                  title: Text(option.label, style: AppTypography.body),
                  onChanged: poll.status == 'live'
                      ? (value) => setState(() {
                            if (value == true) {
                              selected.add(option.id);
                            } else {
                              selected.remove(option.id);
                            }
                          })
                      : null,
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (poll.status == 'live') ...[
                    Expanded(
                      child: AppButton(
                        label: 'Submit vote',
                        onPressed: selected.isEmpty
                            ? null
                            : () async {
                                if (!_requireAuthentication()) return;
                                await ref
                                    .read(interactionsRepositoryProvider)
                                    .vote(poll.id, selected.toList());
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Vote submitted')));
                              },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: AppButton(
                      label: 'View results',
                      variant: AppButtonVariant.secondary,
                      onPressed: () async {
                        if (!_requireAuthentication()) return;
                        final results = await ref
                            .read(interactionsRepositoryProvider)
                            .results(poll.id);
                        if (!mounted) return;
                        showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                                title: Text('${poll.title} results'),
                                content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: results
                                        .map((result) => ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(result.label),
                                            trailing: Text(
                                                '${result.percentage}%',
                                                style: AppTypography
                                                    .bodyStrong)))
                                        .toList())));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _questions(AsyncValue<List<EventQuestion>> state) => state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Unable to load questions: $error',
            style: AppTypography.bodyMuted),
        data: (items) => items.isEmpty
            ? const Text('No approved questions yet.', style: AppTypography.bodyMuted)
            : Column(
                children: items
                    .map((question) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(question.question,
                                          style: AppTypography.bodyStrong),
                                      if (question.answer != null) ...[
                                        const SizedBox(height: 4),
                                        Text(question.answer!,
                                            style: AppTypography.bodyMuted),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.thumb_up_outlined,
                                      color: AppColors.accentStrong),
                                  onPressed: () {
                                    if (_requireAuthentication()) {
                                      ref
                                          .read(interactionsRepositoryProvider)
                                          .upvote(question.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList()),
      );

  Future<void> _askQuestion() async {
    if (!_requireAuthentication()) return;
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ask a question'),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Submit')),
        ],
      ),
    );
    if (text != null && text.trim().isNotEmpty) {
      await ref
          .read(interactionsRepositoryProvider)
          .ask(widget.eventId, text.trim());
      if (mounted) ref.invalidate(eventQuestionsProvider(widget.eventId));
    }
  }
}