import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'package:frontend/elderly/view/binding_requests_page.dart';
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
        actions: [
          BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final hasRequests = state.bindingRequests.isNotEmpty;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.people_alt_rounded,
                        color: AppColors.darkTeal, size: 28),
                    onPressed: () {
                      final cubit = context.read<DashboardCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const BindingRequestsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  if (hasRequests)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.warningRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
              if (state.bindingRequests.isNotEmpty) ...[
                _PendingRequestBanner(count: state.bindingRequests.length),
                const SizedBox(height: 12),
              ],
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

class _PendingRequestBanner extends StatelessWidget {
  const _PendingRequestBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final message = count == 1
        ? 'You have a new family binding request!'
        : 'You have $count new family binding requests!';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.paleMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.darkTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.darkTeal,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final cubit = context.read<DashboardCubit>();
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const BindingRequestsPage(),
                  ),
                ),
              );
            },
            child: const Text(
              'VIEW',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.darkTeal,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
