import 'package:flutter/material.dart';

class NavbarItem {
  const NavbarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isChat = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// True for the Chats tab — shows the live unread-count badge.
  final bool isChat;
}
