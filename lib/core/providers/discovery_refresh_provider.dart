import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/discovery_changes.dart';
import 'core_providers.dart';

// Dedicated public connection: no bearer token or response-body logging.
final discoveryConnectionProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ref.watch(appConfigProvider).apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
  ));
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final discoveryRefreshProvider =
    NotifierProvider.autoDispose<DiscoveryRefresh, int>(DiscoveryRefresh.new);

class DiscoveryRefresh extends AutoDisposeNotifier<int> {
  @override
  int build() {
    final dio = ref.watch(discoveryConnectionProvider);
    DiscoveryChanges? connection;
    void start() {
      connection?.close();
      connection = DiscoveryChanges(dio, refresh)..connect();
    }

    final lifecycle = AppLifecycleListener(
      onResume: () {
        refresh();
        start();
      },
      onPause: () => connection?.close(),
    );
    start();
    ref.onDispose(() {
      connection?.close();
      lifecycle.dispose();
    });
    return 0;
  }

  void refresh() => state++;
}
