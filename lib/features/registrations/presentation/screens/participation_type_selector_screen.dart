import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../config_engine/application/config_engine_providers.dart';
import '../../../events/application/events_providers.dart';

/// Shows only the participation_types this event's EventConfiguration
/// actually enables (Section 8, Phase 3) — never a hardcoded
/// individual/team/viewer list, since the backend is genuinely
/// config-driven here (Section 3's governing principle).
class ParticipationTypeSelectorScreen extends ConsumerWidget {
  final String eventId;
  const ParticipationTypeSelectorScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final configAsync = ref.watch(eventConfigurationProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: eventAsync.when(
          loading: () => const AppSkeleton.form(),
          error: (error, stackTrace) => AppErrorState(
            error: error is AppException ? error : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
          ),
          data: (event) => configAsync.when(
            loading: () => const AppSkeleton.form(),
            error: (error, stackTrace) => AppErrorState(
              error: error is AppException ? error : UnknownException(error.toString()),
              onRetry: () => ref.invalidate(eventConfigurationProvider(eventId)),
            ),
            data: (config) {
              final types = config?.participationTypes ?? [];
              if (types.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      "This event hasn't been configured for registration yet.",
                      style: AppTypography.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(event.name, style: AppTypography.title),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('How would you like to register?', style: AppTypography.bodyMuted),
                  const SizedBox(height: AppSpacing.xl),
                  for (final type in types)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _TypeOption(
                        type: type,
                        onTap: () {
                          if (type == 'team') {
                            context.push(RoutePaths.createTeamPath(eventId));
                          } else {
                            context.push(RoutePaths.registrationFormPath(eventId, type));
                          }
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String type;
  final VoidCallback onTap;
  const _TypeOption({required this.type, required this.onTap});

  IconData get _icon => switch (type) {
        'team' => Icons.groups_rounded,
        'individual' => Icons.person_rounded,
        'viewer' => Icons.visibility_rounded,
        _ => Icons.how_to_reg_rounded,
      };

  String get _label {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1).replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
              child: Icon(_icon, color: AppColors.accentStrong, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(_label, style: AppTypography.bodyStrong)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkSubtle),
          ],
        ),
      ),
    );
  }
}
