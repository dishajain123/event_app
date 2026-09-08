import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../router/route_paths.dart';

const _tabs = [
  (
    path: RoutePaths.home,
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
    label: 'Home'
  ),
  (
    path: RoutePaths.events,
    icon: Icons.event_outlined,
    activeIcon: Icons.event_rounded,
    label: 'Events',
  ),
  (
    path: RoutePaths.myRegistrations,
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment_rounded,
    label: 'Registrations',
  ),
  (
    path: RoutePaths.myTickets,
    icon: Icons.confirmation_number_outlined,
    activeIcon: Icons.confirmation_number_rounded,
    label: 'Tickets',
  ),
  (
    path: RoutePaths.profile,
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profile'
  ),
];

/// The default shell for every authenticated account, regardless of role
/// (Section 3.3). An account with Staff Mode access still lands here first
/// and always can — see app/router/app_router.dart's redirect logic and
/// ProfileScreen's switch tile for how they reach Staff Mode from here.
class PublicModeShell extends StatelessWidget {
  final Widget child;
  const PublicModeShell({super.key, required this.child});

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
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(bottom: false, child: child),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
