import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_app/app/app.dart';
import 'package:event_app/core/config/app_config.dart';
import 'package:event_app/core/providers/core_providers.dart';

void main() {
  testWidgets('shows splash while the app boots', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              apiBaseUrl: 'http://127.0.0.1:8000/api/v1',
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
