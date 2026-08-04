import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/theme/app_colors.dart';

import '../cubit/caregiver_dashboard_cubit.dart';
import '../cubit/caregiver_dashboard_state.dart';
import '../widgets/patient_card.dart';
import '../widgets/patient_search_bar.dart';
import 'previous_patients_page.dart';
import '../../patient_details/patient_details.dart';

class CaregiverDashboardView extends StatelessWidget {
  const CaregiverDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      //backgroundColor: colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: BlocBuilder<CaregiverDashboardCubit, CaregiverDashboardState>(
          builder: (context, state) {
            final activePatients = state.filteredActivePatients;

            return Column(
              children: [
                const SizedBox(height: 8),
                PatientSearchBar(
                  onChanged: (value) =>
                      context.read<CaregiverDashboardCubit>().searchChanged(value),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Patients',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.activePatients.length} patients under your care',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          today,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PreviousPatientsPage(),
                          ),
                        ),
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('Previous Patients'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.darkTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: activePatients.isEmpty
                      ? Center(
                    child: Text(
                      'No active patients found.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: activePatients.length,
                    itemBuilder: (context, index) {
                      final patient = activePatients[index];
                      return PatientCard(
                        patient: patient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatientDetailsPage(
                                patientId: patient.id,
                                patientName: patient.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}