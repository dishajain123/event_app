import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/auth_state_provider.dart';

/// Attempts a silent bootstrap (Section 8, Phase 1) — go_router's redirect
/// logic (see app/router/app_router.dart) is what actually navigates away
/// from here once [authStateProvider] resolves to Unauthenticated or
/// Authenticated; this screen's only job is to trigger that resolution and
/// show something better than a blank white screen while it's in flight.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: _SplashMark(),
        ),
      ),
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.accent.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 12)),
            ],
          ),
          child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 24),
        const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.accentStrong),
        ),
      ],
    );
  }
}
