import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/scaffolds/app_bottom_nav_bar.dart';
import '../router/route_paths.dart';

const _tabs = [
  (
    path: RoutePaths.staffScan,
    icon: Icons.document_scanner_outlined,
    activeIcon: Icons.document_scanner_rounded,
    label: 'Scan',
  ),
  (
    path: RoutePaths.staffTasks,
    icon: Icons.fact_check_outlined,
    activeIcon: Icons.fact_check_rounded,
    label: 'Tasks'
  ),
  (
    path: RoutePaths.staffMyEvents,
    icon: Icons.event_note_outlined,
    activeIcon: Icons.event_note_rounded,
    label: 'My Events',
  ),
  (
    path: RoutePaths.staffProfile,
    icon: Icons.shield_outlined,
    activeIcon: Icons.shield_rounded,
    label: 'Staff'
  ),
  (
    path: RoutePaths.staffIncidents,
    icon: Icons.warning_amber_outlined,
    activeIcon: Icons.warning_amber_rounded,
    label: 'Incidents',
  ),
];

/// Only ever reachable for an account holding at least one Staff-Mode-
/// capable role — enforced by the router's redirect, not by anything in
/// this widget itself. Uses [AppColors.staffModeAccent] as the shared
/// [AppBottomNavBar]'s accent color deliberately — the one visual
/// departure from [PublicModeShell] — so switching modes is instantly
/// recognizable without reading any text, while the bar itself (shape,
/// motion, typography) stays identical to the rest of the app. Navigation
/// behavior is unchanged: tapping a tab still calls
/// `context.go(_tabs[index].path)`.
class StaffModeShell extends StatelessWidget {
  final Widget child;
  const StaffModeShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((tab) => location.startsWith(tab.path));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.staffModeAccentSoft, AppColors.background],
          ),
        ),
        child: SafeArea(bottom: false, child: child),
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: [
          for (final tab in _tabs)
            AppNavBarItem(
                icon: tab.icon, activeIcon: tab.activeIcon, label: tab.label),
        ],
        currentIndex: currentIndex,
        accentColor: AppColors.staffModeAccent,
        onTap: (index) => context.go(_tabs[index].path),
      ),
    );
  }
}
