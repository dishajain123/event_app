import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// One tab's static content — the mutable bits (selection, tap) are
/// supplied separately by [AppBottomNavBar] so the same spec list a shell
/// already builds its routing table from can be reused verbatim.
class AppNavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const AppNavBarItem(
      {required this.icon, required this.activeIcon, required this.label});
}

/// The shared floating bottom navigation bar — used by both
/// [PublicModeShell] and [StaffModeShell] so a visual refresh here reaches
/// every screen in the app at once instead of drifting between two
/// hand-maintained copies. A light frosted-glass pill — the same surface
/// language as [AppCard]/the header's icon buttons, not a heavy dark slab
/// — with a hairline border and a whisper-soft shadow for gentle
/// elevation. The active tab is identified by a small tinted icon
/// backdrop (sized to the icon, never the whole tab), the caller's
/// [accentColor], and a bolder label — muted dark ink for everything
/// else.
class AppBottomNavBar extends StatelessWidget {
  final List<AppNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.accentColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.88),
                  border:
                      Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavBarTab(
                          item: items[i],
                          selected: i == currentIndex,
                          accentColor: accentColor,
                          onTap: () {
                            if (i != currentIndex) onTap(i);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarTab extends StatefulWidget {
  final AppNavBarItem item;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavBarTab({
    required this.item,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_NavBarTab> createState() => _NavBarTabState();
}

class _NavBarTabState extends State<_NavBarTab> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final accentColor = widget.accentColor;
    // A darker, more legible muted tone than [AppColors.inkMuted] — the
    // explicit ask here was readability, so inactive labels read as
    // "quiet" against the light bar, never "faint".
    final inactiveColor = AppColors.ink.withValues(alpha: 0.6);
    final color = selected ? accentColor : inactiveColor;

    return Semantics(
      button: true,
      selected: selected,
      label: widget.item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _setPressed(false);
            widget.onTap();
          },
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          splashColor: accentColor.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: AnimatedScale(
              scale: _pressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 110),
              curve: Curves.easeOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 42,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: Icon(
                        selected ? widget.item.activeIcon : widget.item.icon,
                        key: ValueKey(selected),
                        color: color,
                        size: selected ? 23 : 21,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: AppTypography.caption.copyWith(
                        fontSize: selected ? 12 : 11,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: selected ? 0.1 : 0,
                        height: 1.1,
                        color: color,
                      ),
                      child: Text(
                        widget.item.label,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
