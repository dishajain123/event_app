import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/providers/core_providers.dart';

/// Run with:
///   flutter run --target lib/main_development.dart --dart-define-from-file=config/development.json
/// (or config/development.local.json for a physical device — see
/// config/development.physical-device.example.json)
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
