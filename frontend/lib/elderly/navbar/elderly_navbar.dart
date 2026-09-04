import 'package:flutter/material.dart';

import 'package:frontend/elderly/navbar/navbar_button.dart';
import 'package:frontend/elderly/navbar/navbar_item.dart';
import 'package:frontend/l10n/l10n.dart';

class ElderlyBottomNavBar extends StatelessWidget {
  const ElderlyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static List<NavbarItem> _items(BuildContext context) => [
    NavbarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: context.l10n.homeLabel,
    ),
    NavbarItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: context.l10n.dashboardNavCaregivers,
    ),
    NavbarItem(
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication,
      label: context.l10n.dashboardNavMedicine,
    ),
    NavbarItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: context.l10n.dashboardNavChat,
      isChat: true,
    ),
    NavbarItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: context.l10n.profileLabel,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = _items(context);

    return Container(
      decoration: BoxDecoration(
        // color: colorScheme.surface,
        color: const Color(0xFFFBFEFC),
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SizedBox(
            height: 72,
            child: Row(
              children: List.generate(items.length, (index) {
                final isSelected = index == selectedIndex;
                final item = items[index];
                return Expanded(
                  child: NavbarButton(
                    icon: isSelected ? item.activeIcon : item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onPressed: () => onChanged(index),
                    showChatBadge: item.isChat,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
