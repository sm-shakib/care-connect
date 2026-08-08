import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/family_monitoring/view/edit_reminders_page.dart';
import 'package:frontend/family/family_monitoring/widgets/available_caregivers_card.dart';
import 'package:frontend/family/family_monitoring/widgets/blood_pressure_card.dart';
import 'package:frontend/family/family_monitoring/widgets/caregiver_status_card.dart';
import 'package:frontend/family/family_monitoring/widgets/heart_rate_card.dart';
import 'package:frontend/family/family_monitoring/widgets/live_location_card.dart';
import 'package:frontend/family/family_monitoring/widgets/medical_progress_section.dart';
import 'package:frontend/family/family_monitoring/widgets/medication_section.dart';
import 'package:frontend/family/family_monitoring/widgets/monitoring_header.dart';
import 'package:frontend/family/models/elder.dart';
import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/shared/reminders/reminders.dart';
import 'package:frontend/theme/app_colors.dart';

class FamilyMonitoringView extends StatelessWidget {
  const FamilyMonitoringView({
    required this.elder,
    super.key,
  });

  final Elder elder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          MonitoringHeader(
            elderName: elder.name,
            imageUrl: elder.imageUrl,
            gender: elder.gender,
          ),

          const SizedBox(height: 24),

          /// Care Team Section (Active Caregivers)
          if (elder.caregivers.isNotEmpty) ...[
            const Text(
              'Active Caregivers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowestLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.outlineVariantLight.withValues(alpha: 0.8)),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < elder.caregivers.length; i++) ...[
                    CaregiverStatusCard(
                      caregiverName: elder.caregivers[i],
                      onTap: () {
                        // Handled inside widget
                      },
                    ),
                    if (i != elder.caregivers.length - 1)
                      Divider(
                          height: 1,
                          color: AppColors.outlineVariantLight
                              .withValues(alpha: 0.3)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const Text(
            'Browse Caregivers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          /// Available Caregivers card
          AvailableCaregiversCard(
            onTap: () {
              // Set the booking context and notify the parent to switch tabs
              context.read<FamilyDashboardCubit>().startBookingForElder(elder);
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Health Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

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

          /// Other Reminders
          OtherRemindersSection(reminders: elder.otherReminders),

          const SizedBox(height: 24),

          /// Medical Progress
          // MedicalProgressSection(records: elder.medicalRecords),

          /// Appointments
          AppointmentsSection(appointments: elder.appointments),

          const SizedBox(height: 24),
        ],
      ),
        ),
        _BottomActionButtons(elder: elder),
      ],
    );
  }
}

class _BottomActionButtons extends StatelessWidget {
  const _BottomActionButtons({required this.elder});

  final Elder elder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _ChatButton(elder: elder),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _EditRemindersButton(elder: elder),
          ),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.elder});

  final Elder elder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () async {
          // Family chats with the elder's assigned (primary) caregiver.
          final contactName = elder.caregivers.isNotEmpty ? elder.caregivers.first : 'Care Team';
          final repository = MockChatRepository.instance;
          final caregiver =
              ChatDirectory.resolveOrCreateContact(contactName, role: ChatRole.caregiver);
          final conversation = await repository.createDirectConversation(
            currentUser: ChatDirectory.asifRahman,
            other: caregiver,
          );
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConversationPage(
                repository: repository,
                conversationId: conversation.id,
                currentUser: ChatDirectory.asifRahman,
              ),
            ),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline, size: 20),
        label: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTeal,
          side: const BorderSide(color: AppColors.darkTeal, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _EditRemindersButton extends StatelessWidget {
  const _EditRemindersButton({required this.elder});

  final Elder elder;

  @override
  Widget build(BuildContext context) {
    final dashboardCubit = context.read<FamilyDashboardCubit>();

    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: dashboardCubit,
                child: FamilyEditRemindersPage(elderId: elder.id),
              ),
            ),
          );
        },
        icon: const Icon(Icons.edit_document),
        label: const Text(
          'Edit Reminders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
