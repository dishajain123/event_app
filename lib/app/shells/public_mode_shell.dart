import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/scaffolds/app_bottom_nav_bar.dart';
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

/// The default shell for every authenticated account, regardless of role.
/// An account with Staff Mode access still lands here first and always
/// can — see app/router/app_router.dart's redirect logic and
/// ProfileScreen's switch tile for how they reach Staff Mode from here.
/// Navigation behavior is unchanged: tapping a tab still calls
/// `context.go(_tabs[index].path)` exactly as before — only the bar's
/// look changed, and now lives in the shared [AppBottomNavBar] so
/// [StaffModeShell] stays visually in sync with it.
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
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(bottom: false, child: child),
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: [
          for (final tab in _tabs)
            AppNavBarItem(
                icon: tab.icon, activeIcon: tab.activeIcon, label: tab.label),
        ],
        currentIndex: currentIndex,
        accentColor: AppColors.accent,
        onTap: (index) => context.go(_tabs[index].path),
      ),
    );
  }
}
