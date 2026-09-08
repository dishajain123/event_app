import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
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
/// `context.go(_tabs[index].path)` exactly as before — only the bar
/// itself is now a floating rounded pill instead of a flush
/// [BottomNavigationBar].
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColorStrong,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _tabs[i].icon,
                      activeIcon: _tabs[i].activeIcon,
                      label: _tabs[i].label,
                      selected: i == currentIndex,
                      onTap: () {
                        if (i == currentIndex) return;
                        context.go(_tabs[i].path);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: EdgeInsets.symmetric(horizontal: selected ? 10 : 0),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : icon,
                color: selected ? Colors.white : const Color(0xFF8C90B8),
                size: 22,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: AppTypography.captionSubtle.copyWith(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF8C90B8),
                ),
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}