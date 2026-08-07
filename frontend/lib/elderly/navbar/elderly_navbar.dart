import 'package:flutter/material.dart';

import 'package:frontend/elderly/navbar/navbar_button.dart';
import 'package:frontend/elderly/navbar/navbar_item.dart';


class ElderlyBottomNavBar extends StatelessWidget {
	const ElderlyBottomNavBar({
		super.key,
		required this.selectedIndex,
		required this.onChanged,
	});

	final int selectedIndex;
	final ValueChanged<int> onChanged;

	static const List<NavbarItem> _items = [
		NavbarItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
		NavbarItem(icon: Icons.medication_outlined, activeIcon: Icons.medication, label: 'Medicine'),
		NavbarItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Chat'),
		NavbarItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'My Profile'),
	];

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Container(
			decoration: BoxDecoration(
				color: colorScheme.surface,
				border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
			),
			child: SafeArea(
				top: false,
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
					child: SizedBox(
						height: 72,
						child: Row(
							children: List.generate(_items.length, (index) {
								final isSelected = index == selectedIndex;
								final item = _items[index];
								return Expanded(
									child: NavbarButton(
										icon: isSelected ? item.activeIcon : item.icon,
										label: item.label,
										isSelected: isSelected,
										onPressed: () => onChanged(index),
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
