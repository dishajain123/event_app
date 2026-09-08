import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../config_engine/application/config_engine_providers.dart';
import '../../application/waitlists_providers.dart';

/// [_selectedType]/[_submitting] and [_join] are unchanged — same
/// `joinWaitlistProvider` call with the same arguments.
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
      body: AppBackground(
        child: SafeArea(
          child: event.when(
            loading: () => const AppSkeleton.form(fieldCount: 1),
            error: (error, stackTrace) => AppErrorState(
              error: error is AppException
                  ? error
                  : UnknownException(error.toString()),
              onRetry: () =>
                  ref.invalidate(eventConfigurationProvider(widget.eventId)),
            ),
            data: (configuration) {
              if (configuration == null) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text('Waitlist configuration is unavailable.',
                        style: AppTypography.bodyMuted,
                        textAlign: TextAlign.center),
                  ),
                );
              }
              _selectedType ??= configuration.participationTypes.firstOrNull;
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: AppColors.warning),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'This event is currently full. Choose a participation type to join its queue — you\'ll be notified in order if a spot opens up.',
                              style: AppTypography.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Participation type',
                        style: AppTypography.bodyStrong),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      items: configuration.participationTypes
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
                      decoration: const InputDecoration(hintText: 'Select…'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                        label: 'Join Waitlist',
                        icon: Icons.queue_outlined,
                        fullWidth: true,
                        size: AppButtonSize.large,
                        loading: _submitting,
                        onPressed: _selectedType == null ? null : _join),
                  ],
                ),
              );
            },
          ),
        ),
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
}