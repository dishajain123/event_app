import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/providers/core_providers.dart';

/// Run with:
///   flutter run --target lib/main_staging.dart --dart-define-from-file=config/staging.json
void main() {
  final config = AppConfig.fromEnvironment();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: const EventApp(),
    ),
  );
}
