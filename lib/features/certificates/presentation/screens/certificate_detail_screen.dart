import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../application/certificates_providers.dart';
import '../../data/models/certificate.dart';

/// Provider watched and the `launchUrl(...)` call are unchanged from
/// before — only the presentation was refreshed.
class CertificateDetailScreen extends ConsumerWidget {
  final AppCertificate certificate;
  const CertificateDetailScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(certificateDetailProvider(certificate.id));
    return detail.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Certificate')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Certificate detail')),
          body: Center(
              child: Text('Unable to load certificate: $error',
                  style: AppTypography.bodyMuted))),
      data: (item) => _content(context, ref, item),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, AppCertificate item) {
    final artifactUrl =
        ref.read(certificatesRepositoryProvider).artifactUrl(item);
    final revoked = item.status.toLowerCase() == 'revoked';
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate detail')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      size: 56, color: Colors.white),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    item.title ?? item.certificateNumber,
                    style:
                        AppTypography.headline.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.eventName ?? item.eventId,
                    style: AppTypography.body
                        .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                      label: 'Certificate type',
                      value: item.certificateType ?? item.templateId),
                  if (item.issuerName != null)
                    _DetailRow(label: 'Issuer', value: item.issuerName!),
                  if (item.criteria != null)
                    _DetailRow(label: 'Criteria', value: '${item.criteria}'),
                  _DetailRow(
                      label: 'Certificate number',
                      value: item.certificateNumber),
                  _DetailRow(
                      label: 'Issued', value: '${item.issuedAt.toLocal()}'),
                  _DetailRow(label: 'Status', value: item.status, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (revoked)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                    'This certificate has been revoked and cannot be verified.',
                    style: TextStyle(color: AppColors.danger)),
              ),
            if (!revoked && item.artifactUrl == null)
              const Text('The certificate artifact is currently unavailable.',
                  style: AppTypography.bodyMuted),
            if (!revoked && item.artifactUrl != null) ...[
              AppButton(
                label: 'View certificate',
                icon: Icons.open_in_new_rounded,
                fullWidth: true,
                size: AppButtonSize.large,
                onPressed: () async {
                  final opened = await launchUrl(Uri.parse(artifactUrl),
                      mode: LaunchMode.externalApplication);
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Unable to open certificate artifact.')));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SelectableText('Verification reference: $artifactUrl',
                  style: AppTypography.captionSubtle),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTypography.captionSubtle),
          ),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
    );
  }
}