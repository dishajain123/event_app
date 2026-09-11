import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_app/app/app.dart';
import 'package:event_app/core/config/app_config.dart';
import 'package:event_app/core/providers/core_providers.dart';
import 'package:event_app/core/providers/discovery_refresh_provider.dart';

// The splash test does not exercise the live network connection.
class _IdleDiscovery extends DiscoveryRefresh {
  @override
  int build() => 0;
}

void main() {
  testWidgets('shows splash while the app boots', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          discoveryRefreshProvider.overrideWith(_IdleDiscovery.new),
          appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'http://127.0.0.1:8001/api/v1',
              environmentName: 'test',
              enableNetworkLogging: false,
            ),
          ),
        ],
        child: const EventApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
