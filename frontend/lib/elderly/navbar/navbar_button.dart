import 'package:flutter/material.dart';
import 'package:frontend/elderly/navbar/navbar_item.dart';
import 'package:frontend/theme/app_colors.dart';

class NavbarButton extends StatelessWidget {
  const NavbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required NavbarItem item,
  });

  final Icon icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? AppColors.onPrimaryContainerLight
        : AppColors.onSurfaceVariantLight;

    return Center(
      child: Material(
        color: isSelected
            ? AppColors.primaryContainerLight
            : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme(
                  data: IconThemeData(color: foregroundColor, size: 28),
                  child: icon,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}