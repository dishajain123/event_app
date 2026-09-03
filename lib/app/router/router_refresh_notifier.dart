import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/application/app_mode_controller.dart';
import '../../features/auth/application/auth_state_provider.dart';

/// go_router re-evaluates its `redirect` callback whenever this
/// [Listenable] calls `notifyListeners()` — this is what lets a Riverpod
/// state change (login completing, logout, switching Public/Staff Mode)
/// actually move the user to a different shell, without recreating the
/// [GoRouter] instance itself on every state change (which would be
/// expensive and would reset in-app navigation state unnecessarily).
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(appModeProvider, (_, __) => notifyListeners());
  }
}
