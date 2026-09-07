import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../application/certificates_providers.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificates = ref.watch(myCertificatesProvider);
    final badges = ref.watch(myBadgesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myCertificatesProvider);
          ref.invalidate(myBadgesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Certificates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            certificates.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Unable to load certificates: $error'),
              data: (items) => items.isEmpty
                  ? const Text('No certificates issued yet.')
                  : Column(
                      children: items
                          .map((item) => Card(
                              child: ListTile(
                                  onTap: () => context.push(
                                      RoutePaths.certificateDetail.replaceFirst(
                                          ':certificateId', item.id),
                                      extra: item),
                                  title: Text(item.certificateNumber),
                                  subtitle: Text(
                                      'Status: ${item.status}\\nVerification reference available'))))
                          .toList()),
            ),
            const SizedBox(height: 24),
            const Text('Achievement badges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            badges.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Unable to load badges: $error'),
              data: (items) => items.isEmpty
                  ? const Text('No badges awarded yet.')
                  : Column(
                      children: items
                          .map((item) => Card(
                              child: ListTile(
                                  leading: const Icon(Icons.verified),
                                  title: Text(
                                      'Badge ${item.badgeId.substring(0, 8)}'),
                                  subtitle: Text('Status: ${item.status}'))))
                          .toList()),
            ),
          ],
        ),
      ),
    );
  }
}
