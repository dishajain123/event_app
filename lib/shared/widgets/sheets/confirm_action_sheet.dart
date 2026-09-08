import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/app_button.dart';
import '../inputs/app_text_field.dart';

/// Shows a confirmation bottom sheet and calls [onConfirm]. Function
/// signature is unchanged — [title], [description], [confirmLabel],
/// [danger], [requireReason], [reasonLabel], [onConfirm] are the exact same
/// parameters as before, so every call site (registration submit, payment
/// initiation, staff invitation accept, manual check-in, registration
/// rejection with reason) keeps working unmodified. Visually the sheet now
/// blurs the content behind it and uses the same rounded-sheet + grabber
/// treatment as the rest of the refresh.
Future<bool> showConfirmActionSheet(
  BuildContext context, {
  required String title,
  String? description,
  String confirmLabel = 'Confirm',
  bool danger = false,
  bool requireReason = false,
  String reasonLabel = 'Reason',
  required Future<void> Function(String? reason) onConfirm,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: _ConfirmActionSheetContent(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        danger: danger,
        requireReason: requireReason,
        reasonLabel: reasonLabel,
        onConfirm: onConfirm,
      ),
    ),
  );
  return result ?? false;
}

class _ConfirmActionSheetContent extends StatefulWidget {
  final String title;
  final String? description;
  final String confirmLabel;
  final bool danger;
  final bool requireReason;
  final String reasonLabel;
  final Future<void> Function(String? reason) onConfirm;

  const _ConfirmActionSheetContent({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.danger,
    required this.requireReason,
    required this.reasonLabel,
    required this.onConfirm,
  });

  @override
  State<_ConfirmActionSheetContent> createState() =>
      _ConfirmActionSheetContentState();
}

class _ConfirmActionSheetContentState
    extends State<_ConfirmActionSheetContent> {
  bool _submitting = false;
  String? _errorMessage;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool get _canConfirm =>
      !widget.requireReason || _reasonController.text.trim().isNotEmpty;

  Future<void> _handleConfirm() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await widget.onConfirm(
          widget.requireReason ? _reasonController.text.trim() : null);
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColorStrong,
              blurRadius: 40,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.inkSubtle.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.danger
                        ? AppColors.dangerSoft
                        : AppColors.accentSoft,
                  ),
                  child: Icon(
                    widget.danger
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                    color: widget.danger
                        ? AppColors.danger
                        : AppColors.accentStrong,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: AppTypography.headline),
                      if (widget.description != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(widget.description!,
                            style: AppTypography.bodyMuted),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.requireReason) ...[
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _reasonController,
                label: widget.reasonLabel,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: AppTypography.body.copyWith(color: AppColors.danger),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: widget.confirmLabel,
                    variant: widget.danger
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
                    loading: _submitting,
                    onPressed: _canConfirm ? _handleConfirm : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}