import 'package:flutter/material.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/app_button.dart';

/// Renders the correct message and retry-affordance for a given
/// [AppException] per Section 3.7's exact state matrix:
///  - NetworkException / ServerException → retry offered
///  - ForbiddenException → no retry (retrying won't fix a permission issue)
///  - everything else (ValidationException, NotFoundException, ...) → the
///    backend's own real message is shown verbatim, never replaced with a
///    generic one, per Section 3.7's rule about surfacing real rule-engine
///    rejections rather than hiding them behind boilerplate text.
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
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: AppColors.dangerSoft, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  size: 28, color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title,
                style: AppTypography.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(error.message,
                style: AppTypography.bodyMuted, textAlign: TextAlign.center),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                  label: 'Try again',
                  onPressed: onRetry,
                  variant: AppButtonVariant.secondary),
            ],
          ],
        ),
      ),
    );
  }
}
