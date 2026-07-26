import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/family_monitoring/widgets/appointment_section.dart';
import 'package:frontend/family/family_monitoring/widgets/available_caregivers_card.dart';
import 'package:frontend/family/family_monitoring/widgets/blood_pressure_card.dart';
import 'package:frontend/family/family_monitoring/widgets/caregiver_status_card.dart';
import 'package:frontend/family/family_monitoring/widgets/heart_rate_card.dart';
import 'package:frontend/family/family_monitoring/widgets/live_location_card.dart';
import 'package:frontend/family/family_monitoring/widgets/medical_progress_section.dart';
import 'package:frontend/family/family_monitoring/widgets/medication_section.dart';
import 'package:frontend/family/family_monitoring/widgets/monitoring_header.dart';
import 'package:frontend/family/models/elder.dart';
import 'package:frontend/theme/app_colors.dart';

class FamilyMonitoringView extends StatelessWidget {
  const FamilyMonitoringView({
    required this.elder,
    super.key,
  });

  final Elder elder;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),

        MonitoringHeader(
          elderName: elder.name,
          imageUrl: elder.imageUrl,
          gender: elder.gender,
        ),

        const SizedBox(height: 20),

        /// Care Team Section (Active Caregivers)
        if (elder.caregivers.isNotEmpty) ...[
          const Text(
            'Active Caregivers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
          const SizedBox(height: 12),
          ...elder.caregivers.map((name) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CaregiverStatusCard(
                  caregiverName: name,
                  onTap: () {
                    // Handled inside widget
                  },
                ),
              )),
          const SizedBox(height: 8),
        ],

        /// Available Caregivers card
        AvailableCaregiversCard(
          onTap: () {
            // Set the booking context and notify the parent to switch tabs
            context.read<FamilyDashboardCubit>().startBookingForElder(elder);
          },
        ),

        const SizedBox(height: 16),

        /// Vitals Row
        HeartRateCard(
          heartRate: elder.vitals.heartRate,
          status: elder.vitals.heartRateStatus,
        ),

        const SizedBox(height: 16),

        BloodPressureCard(
          systolic: elder.vitals.systolic,
          diastolic: elder.vitals.diastolic,
          status: elder.vitals.bpStatus,
        ),

        const SizedBox(height: 16),

        /// Live Location
        LiveLocationCard(
          locationImage: 'assets/images/map.png',
          updatedTime: elder.lastLocationUpdate,
        ),

        const SizedBox(height: 24),

        /// Medication Reminder
        MedicationSection(medications: elder.medications),

        const SizedBox(height: 24),

        /// Medical Progress
        MedicalProgressSection(records: elder.medicalRecords),

        const SizedBox(height: 24),

        /// Appointments
        AppointmentSection(appointments: elder.appointments),

        const SizedBox(height: 24),
      ],
    );
  }
}
