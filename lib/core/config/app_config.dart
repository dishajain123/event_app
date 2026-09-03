/// Typed access to compile-time environment configuration.
///
/// Every value here comes from `--dart-define` (see main_development.dart /
/// main_staging.dart / main_production.dart), never hardcoded. This is the
/// one place that knows where the backend lives — every other layer asks
/// [AppConfig.instance], none of them read `String.fromEnvironment` directly.
///
/// Local development note: an Android emulator reaches a backend running on
/// the host machine at `http://10.0.2.2:8000`, never `localhost` (the
/// emulator's own loopback address means something different). A physical
/// device on the same network as the backend uses the host machine's LAN IP
/// instead. Both are just different values passed to the SAME development
/// flavor's `--dart-define-from-file` — never a code change.
class AppConfig {
  final String apiBaseUrl;
  final String environmentName;
  final bool enableNetworkLogging;

  const AppConfig({
    required this.apiBaseUrl,
    required this.environmentName,
    required this.enableNetworkLogging,
  });

  /// Reads the flavor's compile-time defines. Called once, from each
  /// `main_*.dart` entrypoint, before `runApp`.
  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/api/v1',
    );
    const environmentName = String.fromEnvironment(
      'ENVIRONMENT_NAME',
      defaultValue: 'development',
    );
    const enableNetworkLogging = bool.fromEnvironment(
      'ENABLE_NETWORK_LOGGING',
      defaultValue: true,
    );
    return const AppConfig(
      apiBaseUrl: apiBaseUrl,
      environmentName: environmentName,
      enableNetworkLogging: enableNetworkLogging,
    );
  }

  bool get isProduction => environmentName == 'production';
}
