import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../admin_navigation.dart';

/// The single, shared bottom navigation bar for the admin shell.
/// Replaces the four separate (and previously non-functional)
/// per-feature nav bars — this is the only one now.
///
/// Purely presentational: [selected] + [onSelect] are passed in by
/// [AdminShellView], which owns the actual tab-switching logic via
/// [AdminShellCubit].
///
/// Every item fills an equal `Expanded` share of the bar and its pill
/// background stretches to fill that share (`width: double.infinity`),
/// so all 5 buttons are always exactly the same size regardless of
/// label length ("Dashboard" vs "Users") or selected state.
///
/// Fixed [_barHeight] + `Expanded` items + centered content — same
/// overflow-safe pattern used throughout this app, now sized for 5
/// items instead of 4.
class AdminBottomNavBar extends StatelessWidget {
  const AdminBottomNavBar({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final AdminTab selected;
  final ValueChanged<AdminTab> onSelect;

  static const double _barHeight = 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariantLight),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: selected == AdminTab.dashboard,
                  onTap: () => onSelect(AdminTab.dashboard),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.verified_user,
                  label: 'Verification',
                  isActive: selected == AdminTab.verification,
                  onTap: () => onSelect(AdminTab.verification),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.group,
                  label: 'Users',
                  isActive: selected == AdminTab.users,
                  onTap: () => onSelect(AdminTab.users),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.assignment_late,
                  label: 'Complaints',
                  isActive: selected == AdminTab.complaints,
                  onTap: () => onSelect(AdminTab.complaints),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.event_available,
                  label: 'Bookings',
                  isActive: selected == AdminTab.bookings,
                  onTap: () => onSelect(AdminTab.bookings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single nav item. Uses Flutter's built-in implicit-animation
/// widgets (`AnimatedContainer`, `AnimatedScale`, `AnimatedDefaultTextStyle`,
/// `TweenAnimationBuilder`) rather than a full `AnimationController`,
/// since everything here just animates toward whatever `isActive`
/// currently is — no manual controller/dispose needed.
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  static const _duration = Duration(milliseconds: 220);
  static const _curve = Curves.easeOutCubic;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final foreground = widget.isActive
        ? AppColors.onPrimaryContainerLight
        : AppColors.onSurfaceVariantLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          // Small tap-down "squish" for tactile feedback, on top of
          // the selection pop below.
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: _duration,
            curve: _curve,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppColors.primaryContainerLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: widget.isActive ? 1.15 : 1.0,
                      duration: _duration,
                      curve: _curve,
                      child: TweenAnimationBuilder<Color?>(
                        duration: _duration,
                        curve: _curve,
                        tween: ColorTween(end: foreground),
                        builder: (context, color, _) {
                          return Icon(widget.icon, color: color, size: 20);
                        },
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: _duration,
                      curve: _curve,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                        widget.isActive ? FontWeight.w700 : FontWeight.w600,
                        color: foreground,
                      ),
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
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