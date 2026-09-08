import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/identity_documents_providers.dart';
import '../../data/models/identity_document.dart';

const _statusTones = {
  VerificationStatus.pending: StatusTone.warning,
  VerificationStatus.verified: StatusTone.success,
  VerificationStatus.rejected: StatusTone.danger,
};

class IdentityDocumentsScreen extends ConsumerWidget {
  const IdentityDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(myIdentityDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddSheet(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myIdentityDocumentsProvider),
        child: documentsAsync.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, stackTrace) => ListView(
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              AppErrorState(
                error: error is AppException
                    ? error
                    : UnknownException(error.toString()),
                onRetry: () => ref.invalidate(myIdentityDocumentsProvider),
              ),
            ],
          ),
          data: (documents) {
            if (documents.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  AppEmptyState(
                    icon: Icons.badge_outlined,
                    title: 'No documents yet',
                    description:
                        'Add an identity document if an event requires one for verification.',
                    actionLabel: 'Add document',
                    onAction: () => _showAddSheet(context, ref),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: documents.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final doc = documents[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: AppColors.accentSoft,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.badge_outlined,
                            color: AppColors.accentStrong),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                          child: Text(doc.documentType.label,
                              style: AppTypography.bodyStrong)),
                      StatusBadge(
                        label: doc.verificationStatus.label,
                        tone: _statusTones[doc.verificationStatus] ??
                            StatusTone.neutral,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    DocumentType selectedType = DocumentType.aadhaar;
    final numberController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add document', style: AppTypography.headline),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<DocumentType>(
                  initialValue: selectedType,
                  items: [
                    for (final type in DocumentType.values)
                      DropdownMenuItem(value: type, child: Text(type.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => selectedType = value);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Document type'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                    controller: numberController, label: 'Document number'),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Add',
                  fullWidth: true,
                  onPressed: () async {
                    final number = numberController.text.trim();
                    if (number.length < 4) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(
                            content: Text('Enter a valid document number.')),
                      );
                      return;
                    }
                    try {
                      final repository =
                          ref.read(identityDocumentsRepositoryProvider);
                      await repository.upload(
                          documentType: selectedType, documentNumber: number);
                      ref.invalidate(myIdentityDocumentsProvider);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    } on AppException catch (e) {
                      if (sheetContext.mounted) {
                        ScaffoldMessenger.of(sheetContext)
                            .showSnackBar(SnackBar(content: Text(e.message)));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
