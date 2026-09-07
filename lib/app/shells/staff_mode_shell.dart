import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
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
    activeIcon: Icons.warning_amber,
    label: 'Incidents',
  ),
];

/// Only ever reachable for an account holding at least one Staff-Mode-
/// capable role — enforced by the router's redirect (Section 6.5), not by
/// anything in this widget itself. Uses [AppColors.staffModeAccent]
/// throughout deliberately (Section 5.1) so switching modes is instantly
/// recognizable without reading any text — the one deliberate visual
/// departure from the rest of the app.
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
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme:
              Theme.of(context).bottomNavigationBarTheme.copyWith(
                    selectedItemColor: AppColors.staffModeAccent,
                  ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == currentIndex) return;
            context.go(_tabs[index].path);
          },
          items: [
            for (final tab in _tabs)
              BottomNavigationBarItem(
                icon: Icon(tab.icon),
                activeIcon: Icon(tab.activeIcon),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}
