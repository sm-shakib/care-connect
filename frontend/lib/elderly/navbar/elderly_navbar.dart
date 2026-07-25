import 'package:flutter/material.dart';

import 'package:frontend/elderly/navbar/navbar_button.dart';
import 'package:frontend/elderly/navbar/navbar_item.dart';
import 'package:frontend/theme/app_colors.dart';


class ElderlyBottomNavBar extends StatelessWidget {
	const ElderlyBottomNavBar({
		super.key,
		required this.selectedIndex,
		required this.onChanged,
	});

	final int selectedIndex;
	final ValueChanged<int> onChanged;

	static const List<NavbarItem> _items = [
		NavbarItem(icon: Icon(Icons.home_outlined, color: AppColors.primaryLight), label: 'Home'),
		NavbarItem(icon: Icon(Icons.medication_outlined, color: AppColors.primaryLight), label: 'Medicine'),
		NavbarItem(icon: Icon(Icons.chat_bubble_outline, color: AppColors.primaryLight), label: 'Chat'),
		NavbarItem(icon: Icon(Icons.person_outline, color: AppColors.primaryLight), label: 'My Profile'),
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
								return Expanded(
									child: NavbarButton(
										item: _items[index],
										isSelected: index == selectedIndex,
										onPressed: () => onChanged(index), icon: _items[index].icon, label: _items[index].label,
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

