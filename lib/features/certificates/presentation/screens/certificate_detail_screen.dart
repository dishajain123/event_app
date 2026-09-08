import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/certificates_providers.dart';
import '../../data/models/certificate.dart';

class CertificateDetailScreen extends ConsumerWidget {
  final AppCertificate certificate;
  const CertificateDetailScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(certificateDetailProvider(certificate.id));
    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Certificate detail')),
          body: Center(child: Text('Unable to load certificate: $error'))),
      data: (item) => _content(context, ref, item),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, AppCertificate item) {
    final artifactUrl =
        ref.read(certificatesRepositoryProvider).artifactUrl(item);
    final revoked = item.status.toLowerCase() == 'revoked';
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate detail')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.workspace_premium, size: 64),
          const SizedBox(height: 16),
          Text(item.title ?? item.certificateNumber,
              style: Theme.of(context).textTheme.titleLarge),
          Text('Event: ${item.eventName ?? item.eventId}'),
          Text('Certificate type: ${item.certificateType ?? item.templateId}'),
          if (item.issuerName != null) Text('Issuer: ${item.issuerName}'),
          if (item.criteria != null) Text('Criteria: ${item.criteria}'),
          Text('Certificate number: ${item.certificateNumber}'),
          Text('Issued: ${item.issuedAt.toLocal()}'),
          Text('Status: ${item.status}'),
          const SizedBox(height: 24),
          if (revoked)
            const Text(
                'This certificate has been revoked and cannot be verified.'),
          if (!revoked && item.artifactUrl == null)
            const Text('The certificate artifact is currently unavailable.'),
          if (!revoked && item.artifactUrl != null)
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('View certificate'),
              onPressed: () async {
                final opened = await launchUrl(Uri.parse(artifactUrl),
                    mode: LaunchMode.externalApplication);
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Unable to open certificate artifact.')));
                }
              },
            ),
          if (!revoked && item.artifactUrl != null)
            SelectableText('Verification reference: $artifactUrl'),
        ],
      ),
    );
  }
}
