import 'package:flutter/material.dart';
import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/theme/app_colors.dart';

class NavbarButton extends StatelessWidget {
  const NavbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.showChatBadge = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  /// Wraps the icon in [ChatUnreadBadge] — set for the Chats tab only.
  final bool showChatBadge;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? AppColors.darkTeal
        : AppColors.onSurfaceVariantLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showChatBadge
                    ? ChatUnreadBadge(
                        child: Icon(icon, color: foregroundColor, size: 28),
                      )
                    : Icon(icon, color: foregroundColor, size: 28),
                const SizedBox(height: 6),
                // FittedBox shrinks the label instead of letting it
                // truncate on narrow screens / longer labels.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: foregroundColor,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
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
