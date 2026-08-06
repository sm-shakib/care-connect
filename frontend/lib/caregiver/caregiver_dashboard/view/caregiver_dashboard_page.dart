import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/theme/app_colors.dart';

import '../../caregiver_donation/caregiver_donation_tab.dart';
import '../../caregiver_notifications/caregiver_notifications.dart';
import '../../caregiver_profile/caregiver_profile.dart';
import '../cubit/caregiver_dashboard_cubit.dart';
import '../widgets/caregiver_bottom_navbar.dart';
import 'caregiver_dashboard_view.dart';

class CaregiverDashboardPage extends StatefulWidget {
  const CaregiverDashboardPage({super.key});

  @override
  State<CaregiverDashboardPage> createState() => _CaregiverDashboardPageState();
}

class _CaregiverDashboardPageState extends State<CaregiverDashboardPage> {
  int _selectedIndex = 0;

  static const List<String> _titles = ['CareConnect', 'Chats', 'Donations', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverDashboardCubit(),
      child: Builder(
        builder: (context) {
          Widget body;
          switch (_selectedIndex) {
            case 0:
              body = const CaregiverDashboardView();
              break;
            case 1:
              body = ChatInboxPage(
                repository: MockChatRepository.instance,
                currentUser: ChatDirectory.shakibKhan,
                showHeader: false,
              );
              break;
            case 2:
              body = const CaregiverDonationTab();
              break;
            default:
            // showTopBar: false — this shell's own AppBar below already
            // shows "Profile" as the title, so the page's built-in
            // back-arrow + "Profile" bar is hidden to avoid duplication.
              body = const CaregiverProfilePage(showTopBar: false);
          }

          return Scaffold(
            backgroundColor: const Color(0xFFFBFEFC),
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: const Color(0xFFFBFEFC),
              automaticallyImplyLeading: false,
              shape: Border(
                bottom: BorderSide(color: AppColors.outlineVariantLight),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //const Icon(Icons.healing, color: AppColors.darkTeal, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _titles[_selectedIndex],
                    style: const TextStyle(
                      color: AppColors.darkTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.darkTeal),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverNotificationsPage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(child: body),
            bottomNavigationBar: CaregiverBottomNavBar(
              selectedIndex: _selectedIndex,
              onChanged: (index) => setState(() => _selectedIndex = index),
            ),
          );
        },
      ),
    );
  }
}