import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'view/widgets/caregiver_card.dart';
import 'view/widgets/chat_card.dart';
import 'view/widgets/greetings_section.dart';
import 'view/widgets/medication_card.dart';
import '../navbar/elderly_navbar.dart';
import '../../theme/app_colors.dart';


class ElderlyDashboardPage extends StatelessWidget {
  const ElderlyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit()..loadDashboard(),
      child: const _ElderlyDashboardView(),
    );
  }
}

class _ElderlyDashboardView extends StatefulWidget {
  const _ElderlyDashboardView();

  @override
  State<_ElderlyDashboardView> createState() => _ElderlyDashboardViewState();
}

class _ElderlyDashboardViewState extends State<_ElderlyDashboardView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: _AppBarLogo(),
        ),
        title: const Text(
          'CareConnect',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkTeal),
        ),
      ),
      body: SafeArea(
        child: _selectedIndex == 0
            ? const _DashboardHomeBody()
            : const _ComingSoonBody(),
      ),
      bottomNavigationBar: ElderlyBottomNavBar(
        selectedIndex: _selectedIndex,
        onChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}


class _DashboardHomeBody extends StatelessWidget {
  const _DashboardHomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == DashboardStatus.failure) {
          return Center(
            child: Text(
              state.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: context.read<DashboardCubit>().loadDashboard,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              GreetingsSection(userName: state.userName),
              const SizedBox(height: 24),
              MedicationCard(
                medications: state.medications,
                onMarkTaken: (medication) => context
                    .read<DashboardCubit>()
                    .markMedicationTaken(medication.id),
              ),
              const SizedBox(height: 18),
              CaregiverCard(caregiver: state.caregiver),
              const SizedBox(height: 18),
              ChatCard(chat: state.chatPreview),
            ],
          ),
        );
      },
    );
  }
}


class _AppBarLogo extends StatelessWidget {
  const _AppBarLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        //color: AppColors.darkTeal,
      ),
      child: const Icon(
        Icons.medical_services_rounded,
        color: AppColors.darkTeal,
        size: 32,
      ),
    );
  }
}

class _ComingSoonBody extends StatelessWidget {
  const _ComingSoonBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'Coming soon',
        style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
