import 'package:flutter/material.dart';

import '../../../caregiver/caregiver_list/view/caregiver_list_page.dart';
import '../../models/elder.dart';
import '../widgets/available_caregivers_card.dart';
import '../widgets/blood_pressure_card.dart';
import '../widgets/caregiver_status_card.dart';
import '../widgets/heart_rate_card.dart';
import '../widgets/live_location_card.dart';
import '../widgets/active_caregiver_card.dart';
import '../widgets/section_placeholder_card.dart';

class FamilyMonitoringView extends StatelessWidget {
  const FamilyMonitoringView({
    super.key,
    required this.elder,
  });

  final Elder elder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// Header
            MonitoringHeader(
              elderName: elder.name,
            ),

            const SizedBox(height: 20),

            /// Active Caregiver
            CaregiverStatusCard(
              caregiverName: elder.caregiverName,
              onTap: () {
                // TODO:
                // Navigate to Caregiver Details Page
              },
            ),

            const SizedBox(height: 16),

            /// Available Caregivers
            AvailableCaregiversCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CaregiverListPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            /// Heart Rate
            const HeartRateCard(
              heartRate: 72,
              status: "Stable",
            ),

            const SizedBox(height: 16),

            /// Blood Pressure
            const BloodPressureCard(
              systolic: 118,
              diastolic: 75,
              status: "Normal Range",
            ),

            const SizedBox(height: 16),

            /// Live Location
            const LiveLocationCard(
              locationImage: 'assets/images/map.png',
              updatedTime: 'Updated 2 min ago',
            ),

            const SizedBox(height: 24),

            /// Medication Reminder
            const SectionPlaceholderCard(
              title: "Medication Reminder",
              subtitle: "Will be imported from Elder UI",
              icon: Icons.medication,
            ),

            const SizedBox(height: 16),

            /// Medical Progress
            const SectionPlaceholderCard(
              title: "Medical Progress",
              subtitle: "Will be imported from Elder UI",
              icon: Icons.monitor_heart,
            ),

            const SizedBox(height: 16),

            /// Appointments
            const SectionPlaceholderCard(
              title: "Appointments",
              subtitle: "Will be imported from Elder UI",
              icon: Icons.calendar_month,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}