import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_colors.dart';
import '../../../admin_navigation.dart';
import '../../cubit/admin_shell_cubit.dart';
import '../../cubit/admin_shell_state.dart';

/// A shared bottom navigation bar for the admin shell.
/// Supports drag-to-swap reordering via long-press and allows swapping
/// items with the "More" menu.
class AdminBottomNavBar extends StatelessWidget {
  const AdminBottomNavBar({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final AdminTab selected;
  final ValueChanged<AdminTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminShellCubit, AdminShellState>(
      builder: (context, state) {
        final tabs = state.barTabs;

        // Determine if "More" should be highlighted due to a sub-module.
        final isSubModuleActive = state.moreTabs.contains(selected);

        final effectiveSelected = isSubModuleActive ? AdminTab.more : selected;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  for (int i = 0; i < tabs.length; i++)
                    Expanded(
                      child: DragTarget<AdminTab>(
                        onWillAccept: (data) => data != null && data != tabs[i],
                        onAccept: (data) {
                          if (state.barTabs.contains(data)) {
                            final oldIndex = state.barTabs.indexOf(data);
                            context.read<AdminShellCubit>().swapBarTabs(oldIndex, i);
                          } else {
                            context.read<AdminShellCubit>().swapBarWithMore(data, tabs[i]);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          final tab = tabs[i];
                          final info = AdminTabInfo.all[tab]!;
                          final isHovered = candidateData.isNotEmpty;

                          return LongPressDraggable<AdminTab>(
                            key: ValueKey('nav_drag_${tab.name}'),
                            data: tab,
                            delay: const Duration(milliseconds: 500),
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / tabs.length,
                                height: 60,
                                child: _NavItem(
                                  key: ValueKey('nav_feedback_${tab.name}'),
                                  icon: info.icon,
                                  activeIcon: info.activeIcon,
                                  label: info.label,
                                  isSelected: effectiveSelected == tab,
                                  onTap: () {},
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.2,
                              child: _NavItem(
                                icon: info.icon,
                                activeIcon: info.activeIcon,
                                label: info.label,
                                isSelected: effectiveSelected == tab,
                                onTap: () {},
                              ),
                            ),
                            child: _NavItem(
                              key: ValueKey('nav_item_${tab.name}'),
                              icon: info.icon,
                              activeIcon: info.activeIcon,
                              label: info.label,
                              isSelected: effectiveSelected == tab,
                              onTap: () => onSelect(tab),
                              isHovered: isHovered,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isHovered = false,
    super.key,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHovered;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  static const _pressInDuration = Duration(milliseconds: 80);
  static const _pressOutDuration = Duration(milliseconds: 120);

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppColors.darkTeal
        : AppColors.onSurfaceVariantLight;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: (_pressed || widget.isHovered)
                    ? _pressInDuration
                    : _pressOutDuration,
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: _pressed
                      ? AppColors.darkTeal.withOpacity(0.12)
                      : (widget.isHovered
                          ? AppColors.darkTeal.withOpacity(0.18)
                          : AppColors.darkTeal.withOpacity(0)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              AnimatedScale(
                scale: _pressed ? 0.92 : 1.0,
                duration: _pressed ? _pressInDuration : _pressOutDuration,
                curve: Curves.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isSelected ? widget.activeIcon : widget.icon,
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight:
                            widget.isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
