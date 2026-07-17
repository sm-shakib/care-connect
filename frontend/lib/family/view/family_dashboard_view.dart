import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_stats_section.dart';
import '../cubit/family_dashboard_cubit.dart';
import '../cubit/family_dashboard_state.dart';
import '../widgets/elder_card.dart';
import '../widgets/add_elder_button.dart';
import '../family_monitoring/view/family_monitoring_page.dart';

class FamilyDashboardView extends StatelessWidget {
  const FamilyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: const Text(
          'Family Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
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
                    .where((e) => e.hasCaregiver)
                    .length,
              ),

              const SizedBox(height: 25),

              const Text(
                "My Elders",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ...state.filteredElders.map(
                    (elder) => ElderCard(
                  elder: elder,
                  onTap: () {

                    context
                        .read<FamilyDashboardCubit>()
                        .selectElder(elder);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FamilyMonitoringPage(
                                elder: elder,
                            ),
                        ),
                    );

                  },
                ),
              ),

              const SizedBox(height: 25),

              const SizedBox(height: 20),

              AddElderButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Add Elder feature coming soon!',
                      ),
                    ),
                  );
                },
              ),

            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        child: Column(
          children: [

            Icon(
              icon,
              size: 32,
              color: Colors.teal,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

          ],
        ),
      ),
    );
  }
}