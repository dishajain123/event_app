import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../auth/application/auth_state_provider.dart';
import '../../application/interactions_providers.dart';
import '../../data/models/interaction.dart';

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
      appBar: AppBar(title: const Text('Live interactions')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(eventPollsProvider(widget.eventId));
          ref.invalidate(eventQuestionsProvider(widget.eventId));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Live polls',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _polls(polls),
            const SizedBox(height: 24),
            const Text('Questions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _questions(questions),
            OutlinedButton.icon(
              onPressed: _askQuestion,
              icon: const Icon(Icons.question_answer_outlined),
              label: const Text('Ask a question'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _polls(AsyncValue<List<EventPoll>> state) => state.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Text('Unable to load polls: $error'),
        data: (items) => items.isEmpty
            ? const Text('No live polls.')
            : Column(children: items.map(_pollCard).toList()),
      );

  Widget _pollCard(EventPoll poll) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(poll.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ...poll.options.map((option) => CheckboxListTile(
                    value: selected.contains(option.id),
                    title: Text(option.label),
                    onChanged: poll.status == 'live'
                        ? (value) => setState(() {
                              if (value == true) {
                                selected.add(option.id);
                              } else {
                                selected.remove(option.id);
                              }
                            })
                        : null,
                  )),
              if (poll.status == 'live')
                FilledButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () async {
                          if (!_requireAuthentication()) return;
                          await ref
                              .read(interactionsRepositoryProvider)
                              .vote(poll.id, selected.toList());
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vote submitted')));
                        },
                  child: const Text('Submit vote'),
                ),
              OutlinedButton(
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
                                      title: Text(result.label),
                                      trailing: Text('${result.percentage}%')))
                                  .toList())));
                },
                child: const Text('View results'),
              ),
            ],
          ),
        ),
      );

  Widget _questions(AsyncValue<List<EventQuestion>> state) => state.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Text('Unable to load questions: $error'),
        data: (items) => items.isEmpty
            ? const Text('No approved questions yet.')
            : Column(
                children: items
                    .map((question) => ListTile(
                          title: Text(question.question),
                          subtitle: question.answer == null
                              ? null
                              : Text(question.answer!),
                          trailing: IconButton(
                            icon: const Icon(Icons.thumb_up_outlined),
                            onPressed: () {
                              if (_requireAuthentication()) {
                                ref
                                    .read(interactionsRepositoryProvider)
                                    .upvote(question.id);
                              }
                            },
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
