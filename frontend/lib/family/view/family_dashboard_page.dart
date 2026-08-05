import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_list/view/caregiver_list_page.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/cubit/family_dashboard_state.dart';
import 'package:frontend/family/family_monitoring/view/family_monitoring_view.dart';
import 'package:frontend/family/navbar/family_navbar.dart';
import 'package:frontend/family/view/donation/family_donation_tab.dart';
import 'package:frontend/family/view/family_dashboard_view.dart';
import 'package:frontend/family/view/notifications/family_notifications_page.dart';
import 'package:frontend/family/view/profile/family_profile_page.dart';
import 'package:frontend/login/view/login_page.dart';
import 'package:frontend/theme/app_colors.dart';

class FamilyDashboardPage extends StatefulWidget {
  const FamilyDashboardPage({super.key});

  @override
  State<FamilyDashboardPage> createState() => _FamilyDashboardPageState();
}

class _FamilyDashboardPageState extends State<FamilyDashboardPage> {
  int _selectedIndex = 0;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warningRed),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilyDashboardCubit()..loadElders(),
      child: BlocConsumer<FamilyDashboardCubit, FamilyDashboardState>(
        listenWhen: (previous, current) =>
        previous.bookingForElder == null && current.bookingForElder != null,
        listener: (context, state) {
          // If a booking context is started, switch to the Caregivers tab
          setState(() {
            _selectedIndex = 1;
          });
        },
        builder: (context, state) {
          // Determine the body content based on selection
          Widget body;
          String title = 'Family Dashboard';

          if (_selectedIndex == 0) {
            if (state.selectedElder != null) {
              body = FamilyMonitoringView(elder: state.selectedElder!);
              title = 'Monitoring ${state.selectedElder!.name}';
            } else {
              body = const FamilyDashboardView();
              title = 'Family Dashboard';
            }
          } else if (_selectedIndex == 1) {
            body = const CaregiverListPage();
            title = state.bookingForElder != null
                ? 'Select for ${state.bookingForElder!.name}'
                : 'Available Caregivers';
          } else if (_selectedIndex == 2) {
            body = const FamilyDonationTab();
            title = 'Donation';
          } else {
            body = const FamilyProfilePage();
            title = 'My Profile';
          }

          return Scaffold(
            // backgroundColor: AppColors.backgroundLight,
            backgroundColor: const Color(0xFFFBFEFC),
            appBar: AppBar(
              elevation: 0,
              // backgroundColor: Theme.of(context).colorScheme.surface,
              backgroundColor: const Color(0xFFFBFEFC),
              scrolledUnderElevation: 0,
              shape: Border(
                bottom: BorderSide(color: AppColors.outlineVariantLight),
              ),
              automaticallyImplyLeading: false,
              leading: (state.selectedElder != null && _selectedIndex == 0)
                  ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
                onPressed: () => context.read<FamilyDashboardCubit>().selectElder(null),
              )
                  : null,
              title: Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.darkTeal),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FamilyNotificationsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: body,
            ),
            bottomNavigationBar: FamilyBottomNavBar(
              selectedIndex: _selectedIndex,
              onChanged: (index) {
                setState(() {
                  _selectedIndex = index;

                  // If user clicks the Home tab (index 0), always go back to the dashboard list
                  if (index == 0) {
                    context.read<FamilyDashboardCubit>().selectElder(null);
                  }

                  // Clear selection if switching tabs away from home
                  if (index != 0) {
                    context.read<FamilyDashboardCubit>().selectElder(null);
                  }

                  // Clear booking context if switching away from caregivers tab
                  if (index != 1) {
                    context.read<FamilyDashboardCubit>().clearBookingContext();
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}