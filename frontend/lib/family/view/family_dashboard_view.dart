import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/cubit/family_dashboard_state.dart';
import 'package:frontend/family/view/add_elder_page.dart';
import 'package:frontend/family/widgets/add_elder_button.dart';
import 'package:frontend/family/widgets/dashboard_header.dart';
import 'package:frontend/family/widgets/elder_card.dart';
import 'package:frontend/family/widgets/quick_stats_section.dart';
import 'package:frontend/theme/app_colors.dart';

class FamilyDashboardView extends StatelessWidget {
  const FamilyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// Welcome
            const DashboardHeader(),

            const SizedBox(height: 25),

            /// Quick Stats
            QuickStatsSection(
              totalElders: state.elders.length,
              totalCaregivers: state.elders
                  .fold(0, (sum, e) => sum + e.caregivers.length),
            ),

            const SizedBox(height: 25),

            const Text(
              'My Elders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.deepTrustBlue,
              ),
            ),

            const SizedBox(height: 15),

            if (state.elders.isEmpty)
              const _EmptyEldersState()
            else
              ...state.filteredElders.map(
                (elder) => ElderCard(
                  elder: elder,
                  onTap: () {
                    // Update state to show monitoring view within the same tab
                    context.read<FamilyDashboardCubit>().selectElder(elder);
                  },
                ),
              ),

            const SizedBox(height: 20),

            AddElderButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AddElderPage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _EmptyEldersState extends StatelessWidget {
  const _EmptyEldersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.people_outline, size: 80, color: AppColors.outlineVariantLight),
            const SizedBox(height: 16),
            const Text(
              'No elders added yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your loved ones to start monitoring their care.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
          ],
        ),
      ),
    );
  }
}
