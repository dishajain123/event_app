import 'package:flutter/material.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/app_button.dart';

/// Renders the correct message and retry-affordance for a given
/// [AppException]. Public API and the state matrix are unchanged from
/// before: NetworkException / ServerException → retry offered;
/// ForbiddenException → no retry; every other exception's real backend
/// message is shown verbatim, never replaced with generic text. Only the
/// presentation is refreshed (gradient icon blob, matching [AppEmptyState]).
class AppErrorState extends StatelessWidget {
  final AppException error;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final (title, showRetry) = switch (error) {
      NetworkException() => ('Connection problem', true),
      ServerException() => ('Something went wrong on our end', true),
      ForbiddenException() => ("You don't have access to this", false),
      NotFoundException() => ('Not found', false),
      UnauthorizedException() => ('Session ended', false),
      ValidationException() => ("That didn't work", false),
      UnknownException() => ('Something unexpected happened', true),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.dangerSoft,
                    AppColors.dangerSoft.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 30, color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title,
                style: AppTypography.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(error.message,
                style: AppTypography.bodyMuted, textAlign: TextAlign.center),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: 'Try again',
                  onPressed: onRetry,
                  icon: Icons.refresh_rounded,
                  variant: AppButtonVariant.secondary),
            ],
          ],
        ),
      ),
    );
  }
}