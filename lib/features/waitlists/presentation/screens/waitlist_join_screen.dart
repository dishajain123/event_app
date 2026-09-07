import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../config_engine/application/config_engine_providers.dart';
import '../../application/waitlists_providers.dart';

class WaitlistJoinScreen extends ConsumerStatefulWidget {
  final String eventId;
  const WaitlistJoinScreen({super.key, required this.eventId});

  @override
  ConsumerState<WaitlistJoinScreen> createState() => _WaitlistJoinScreenState();
}

class _WaitlistJoinScreenState extends ConsumerState<WaitlistJoinScreen> {
  String? _selectedType;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventConfigurationProvider(widget.eventId));
    return Scaffold(
      appBar: AppBar(title: const Text('Join waitlist')),
      body: event.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (configuration) {
          if (configuration == null) {
            return const Center(child: Text('Waitlist configuration is unavailable.'));
          }
          _selectedType ??= configuration.participationTypes.firstOrNull;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('This event is currently full.'),
              const SizedBox(height: AppSpacing.md),
              const Text(
                  'Choose the participation type to join its FIFO queue.'),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: configuration.participationTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                decoration:
                    const InputDecoration(labelText: 'Participation type'),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                  label: 'Join Waitlist',
                  fullWidth: true,
                  loading: _submitting,
                  onPressed: _selectedType == null ? null : _join),
            ]),
          );
        },
      ),
    );
  }

  Future<void> _join() async {
    setState(() => _submitting = true);
    try {
      final entry = await ref.read(joinWaitlistProvider)(
          eventId: widget.eventId, participationType: _selectedType!);
      ref.invalidate(myWaitlistsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'You joined the waitlist${entry.position == null ? '' : ' at position ${entry.position}'}.')));
        context.pop();
      }
    } on AppException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
