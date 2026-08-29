import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/l10n/l10n.dart';
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
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<CaregiverDashboardCubit>().loadPatients(),
          child: BlocBuilder<CaregiverDashboardCubit, CaregiverDashboardState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final activePatients = state.filteredActivePatients;

              return Column(
                children: [
                  const SizedBox(height: 8),
                  PatientSearchBar(
                    onChanged: (value) => context
                        .read<CaregiverDashboardCubit>()
                        .searchChanged(value),
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
                                context.l10n.activePatientsTitle,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.patientsUnderCareSubtitle(
                                  state.activePatients.length,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer
                                .withValues(alpha: 0.3),
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
                  const SizedBox(height: 18),
                  Expanded(
                    child: activePatients.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Text(
                                    context.l10n.noActivePatientsFound,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PreviousPatientsPage(),
                          ),
                        ),
                        icon: const Icon(Icons.history),
                        label: Text(
                          context.l10n.previousPatientsLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkTeal,
                          side: const BorderSide(
                            color: AppColors.darkTeal,
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}