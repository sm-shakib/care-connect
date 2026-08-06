import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../admin_navigation.dart';

/// The single, shared bottom navigation bar for the admin shell.
/// Matches the look and feel of the family app's navigation bar.
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
    // The 4 main destinations shown in the bar.
    final items = [
      AdminTab.dashboard,
      AdminTab.verification,
      AdminTab.bookings,
      AdminTab.more,
    ];

    // Highlight "More" (index 3) if any sub-module is selected.
    int currentIndex;
    switch (selected) {
      case AdminTab.dashboard:
        currentIndex = 0;
      case AdminTab.verification:
        currentIndex = 1;
      case AdminTab.bookings:
        currentIndex = 2;
      case AdminTab.users:
      case AdminTab.complaints:
      case AdminTab.central_fund:
      case AdminTab.more:
        currentIndex = 3;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => onSelect(items[index]),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.darkTeal,
        unselectedItemColor: AppColors.onSurfaceVariantLight,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
        ),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Verification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            activeIcon: Icon(Icons.event_available),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
