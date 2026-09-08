import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
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
/// this widget itself. Uses [AppColors.staffModeAccent] throughout
/// deliberately so switching modes is instantly recognizable without
/// reading any text — the one deliberate visual departure from the rest
/// of the app, carried into the floating nav bar to match
/// [PublicModeShell]'s refreshed style. Navigation behavior is unchanged:
/// tapping a tab still calls `context.go(_tabs[index].path)`.
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
                    child: _StaffNavItem(
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

class _StaffNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StaffNavItem({
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
          decoration: BoxDecoration(
            color: selected
                ? AppColors.staffModeAccent.withValues(alpha: 0.24)
                : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : icon,
                color:
                    selected ? AppColors.staffModeAccent : const Color(0xFF8C90B8),
                size: 22,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: AppTypography.captionSubtle.copyWith(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.staffModeAccent
                      : const Color(0xFF8C90B8),
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