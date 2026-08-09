import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_cubit.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_state.dart';
import 'package:frontend/caregiver/models/caregiver.dart';
import 'package:frontend/caregiver/widgets/caregiver_card.dart';
import 'package:frontend/caregiver/widgets/caregiver_filter_chip.dart';
import 'package:frontend/caregiver/widgets/caregiver_search_bar.dart';
import 'package:frontend/l10n/l10n.dart';

/// Reusable caregiver browsing UI: search bar, specialty filter chips, and
/// the resulting caregiver list.
///
/// Must be placed under a [CaregiverListCubit] (via [BlocProvider]). An
/// optional [banner] can be rendered above the search bar (e.g. to surface
/// booking context), while [onCaregiverTap] controls what happens when a
/// caregiver card is tapped, letting callers reuse this body across
/// different roles/flows (family booking, elder browsing, etc.).
class CaregiverListBody extends StatelessWidget {
  const CaregiverListBody({
    super.key,
    required this.onCaregiverTap,
    this.banner,
  });

  final ValueChanged<Caregiver> onCaregiverTap;
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaregiverListCubit, CaregiverListState>(
      builder: (context, state) {
        return Column(
          children: [
            if (banner != null) banner!,

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
                    label: context.l10n.filterAll,
                    selected: state.selectedFilter == "All",
                    onTap: () {
                      context.read<CaregiverListCubit>().filterCaregivers("All");
                    },
                  ),
                  CaregiverFilterChip(
                    label: context.l10n.filterPhysiotherapy,
                    selected: state.selectedFilter == "Physiotherapy",
                    onTap: () {
                      context
                          .read<CaregiverListCubit>()
                          .filterCaregivers("Physiotherapy");
                    },
                  ),
                  CaregiverFilterChip(
                    label: context.l10n.filterSeniorCare,
                    selected: state.selectedFilter == "Senior Care",
                    onTap: () {
                      context
                          .read<CaregiverListCubit>()
                          .filterCaregivers("Senior Care");
                    },
                  ),
                  CaregiverFilterChip(
                    label: context.l10n.filterHomeNursing,
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
                    onTap: () => onCaregiverTap(caregiver),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
