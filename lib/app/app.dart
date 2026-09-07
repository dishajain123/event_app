import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';
import '../features/notifications/application/push_token_source.dart';

class EventApp extends ConsumerStatefulWidget {
  const EventApp({super.key});

  @override
  ConsumerState<EventApp> createState() => _EventAppState();
}

class _EventAppState extends ConsumerState<EventApp> {
  @override
  void initState() {
    super.initState();
    PushTokenSource.pendingDeepLink.addListener(_openPendingDeepLink);
  }

  @override
  void dispose() {
    PushTokenSource.pendingDeepLink.removeListener(_openPendingDeepLink);
    super.dispose();
  }

  void _openPendingDeepLink() {
    final path = PushTokenSource.pendingDeepLink.value;
    if (path == null) return;
    PushTokenSource.pendingDeepLink.value = null;
    ref.read(goRouterProvider).go(path);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Event App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
