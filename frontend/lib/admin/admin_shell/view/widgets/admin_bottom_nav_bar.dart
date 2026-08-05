import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../admin_navigation.dart';

/// The single, shared bottom navigation bar for the admin shell.
/// Matches the look and feel of the family app's navigation bar
/// while maintaining admin-specific tabs.
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
    // Dynamically filter tabs to allow easy toggling of "Users"
    // without breaking the index mapping of the other tabs.
    final visibleTabs = AdminTab.values.where((tab) {
      // Toggle this to show/hide the Users tab
      if (tab == AdminTab.users) return false;
      if (tab == AdminTab.central_fund) return false;
      return true;
    }).toList();

    final currentIndex = visibleTabs.indexOf(selected);

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
        // Default to first tab if the selected one is hidden (e.g. Users)
        currentIndex: currentIndex < 0 ? 0 : currentIndex,
        onTap: (index) => onSelect(visibleTabs[index]),
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
          // To bring back Users, uncomment the line in visibleTabs above
          // AND the item below.
          /*
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Users',
          ),
          */
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late_outlined),
            activeIcon: Icon(Icons.assignment_late),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            activeIcon: Icon(Icons.event_available),
            label: 'Bookings',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Fund',
          ),*/
        ],
      ),
    );
  }
}
