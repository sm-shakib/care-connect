import 'package:flutter/material.dart';

class NavbarItem {
  const NavbarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
