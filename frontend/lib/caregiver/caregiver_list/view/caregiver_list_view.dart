import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/caregiver_search_bar.dart';
import '../../widgets/caregiver_filter_chip.dart';
import '../../widgets/caregiver_card.dart';
import '../cubit/caregiver_list_cubit.dart';
import '../cubit/caregiver_list_state.dart';
import '../../caregiver_details/view/caregiver_details_page.dart';
import '../../caregiver_details/view/caregiver_details_page.dart';

class CaregiverListView extends StatelessWidget {
  const CaregiverListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Caregivers'),
        centerTitle: true,
      ),body: BlocBuilder<CaregiverListCubit, CaregiverListState>(
      builder: (context, state) {
        return Column(
          children: [

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
                      context.read<CaregiverListCubit>()
                          .filterCaregivers("All");
                    },
                  ),

                  CaregiverFilterChip(
                    label: "Physiotherapy",
                    selected:
                    state.selectedFilter == "Physiotherapy",
                    onTap: () {
                      context.read<CaregiverListCubit>()
                          .filterCaregivers("Physiotherapy");
                    },
                  ),

                  CaregiverFilterChip(
                    label: "Senior Care",
                    selected:
                    state.selectedFilter == "Senior Care",
                    onTap: () {
                      context.read<CaregiverListCubit>()
                          .filterCaregivers("Senior Care");
                    },
                  ),

                  CaregiverFilterChip(
                    label: "Home Nursing",
                    selected:
                    state.selectedFilter == "Home Nursing",
                    onTap: () {
                      context.read<CaregiverListCubit>()
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
                        MaterialPageRoute(
                          builder: (_) => CaregiverDetailsPage(
                            caregiver: caregiver,
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
    );
  }
}