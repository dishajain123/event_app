import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/guardians_providers.dart';

/// Provider watched is unchanged from before — only the row presentation
/// (now [AppCard]) was refreshed.
class MyChildrenScreen extends ConsumerWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(myChildrenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(RoutePaths.addChild),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myChildrenProvider),
          child: childrenAsync.when(
            loading: () => const AppSkeleton.cardList(),
            error: (error, stackTrace) => ListView(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myChildrenProvider),
                ),
              ],
            ),
            data: (children) {
              if (children.isEmpty) {
                return ListView(
                  children: [
                    const SizedBox(height: AppSpacing.xxxl),
                    AppEmptyState(
                      icon: Icons.child_care_rounded,
                      title: 'No children added yet',
                      description:
                          "Add a child's profile to register them for an event.",
                      actionLabel: 'Add child',
                      onAction: () => context.push(RoutePaths.addChild),
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: children.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final child = children[index];
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                              color: AppColors.accentSoft,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.child_care_rounded,
                              color: AppColors.accentStrong),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(child.fullName,
                                  style: AppTypography.bodyStrong),
                              Text('${child.ageInYears} years old',
                                  style: AppTypography.caption),
                            ],
                          ),
                        ),
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