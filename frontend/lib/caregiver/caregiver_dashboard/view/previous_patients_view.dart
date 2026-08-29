import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/widgets/care_connect_app_bar.dart';

import '../cubit/caregiver_dashboard_cubit.dart';
import '../cubit/caregiver_dashboard_state.dart';
import '../widgets/patient_card.dart';
import '../widgets/patient_search_bar.dart';
import 'package:frontend/l10n/l10n.dart';
import '../../patient_details/patient_details.dart';

class PreviousPatientsView extends StatelessWidget {
  const PreviousPatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      //backgroundColor: colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: BlocBuilder<CaregiverDashboardCubit, CaregiverDashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final previousPatients = state.filteredPreviousPatients;

            return Column(
              children: [
                const CareConnectAppBar(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.previousPatientsLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                PatientSearchBar(
                  onChanged: (value) =>
                      context.read<CaregiverDashboardCubit>().searchChanged(value),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: previousPatients.isEmpty
                      ? Center(
                    child: Text(
                      context.l10n.noPreviousPatientsFound,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: previousPatients.length,
                    itemBuilder: (context, index) {
                      final patient = previousPatients[index];
                      return PatientCard(
                        patient: patient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
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