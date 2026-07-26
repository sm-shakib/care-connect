import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_details/view/caregiver_details_page.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_cubit.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_state.dart';
import 'package:frontend/caregiver/widgets/caregiver_card.dart';
import 'package:frontend/caregiver/widgets/caregiver_filter_chip.dart';
import 'package:frontend/caregiver/widgets/caregiver_search_bar.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/cubit/family_dashboard_state.dart';
import 'package:frontend/theme/app_colors.dart';

class CaregiverListView extends StatelessWidget {
  const CaregiverListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Capture the family cubit here to pass it into the details route
    final familyCubit = context.read<FamilyDashboardCubit>();

    return Material(
      color: Colors.transparent,
      child: BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
        builder: (context, familyState) {
          final bookingElder = familyState.bookingForElder;

          return BlocBuilder<CaregiverListCubit, CaregiverListState>(
            builder: (context, state) {
              return Column(
                children: [
                  if (bookingElder != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      color: AppColors.paleMint,
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.darkTeal, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Finding professional for: ${bookingElder.name}',
                              style: const TextStyle(
                                  color: AppColors.darkTeal,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: AppColors.darkTeal),
                            onPressed: () =>
                                familyCubit.clearBookingContext(),
                          ),
                        ],
                      ),
                    ),

                  /// Search Bar
                  CaregiverSearchBar(
                    onChanged: (value) {
                      context.read<CaregiverListCubit>().searchCaregiver(value);
                    },
                  ),

                  /// Filter Chips
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        CaregiverFilterChip(
                          label: "All",
                          selected: state.selectedFilter == "All",
                          onTap: () {
                            context
                                .read<CaregiverListCubit>()
                                .filterCaregivers("All");
                          },
                        ),
                        CaregiverFilterChip(
                          label: "Physiotherapy",
                          selected: state.selectedFilter == "Physiotherapy",
                          onTap: () {
                            context
                                .read<CaregiverListCubit>()
                                .filterCaregivers("Physiotherapy");
                          },
                        ),
                        CaregiverFilterChip(
                          label: "Senior Care",
                          selected: state.selectedFilter == "Senior Care",
                          onTap: () {
                            context
                                .read<CaregiverListCubit>()
                                .filterCaregivers("Senior Care");
                          },
                        ),
                        CaregiverFilterChip(
                          label: "Home Nursing",
                          selected: state.selectedFilter == "Home Nursing",
                          onTap: () {
                            context
                                .read<CaregiverListCubit>()
                                .filterCaregivers("Home Nursing");
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Caregiver List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: state.filteredCaregivers.length,
                      itemBuilder: (context, index) {
                        final caregiver = state.filteredCaregivers[index];
                        return CaregiverCard(
                          caregiver: caregiver,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => BlocProvider.value(
                                  value: familyCubit,
                                  child: CaregiverDetailsPage(
                                    caregiver: caregiver,
                                    bookingForElder: bookingElder,
                                  ),
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
          );
        },
      ),
    );
  }
}
