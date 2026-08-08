import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_details/view/caregiver_details_page.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_cubit.dart';
import 'package:frontend/caregiver/caregiver_list/view/caregiver_list_body.dart';
import 'package:frontend/elderly/view/binding_requests_page.dart';
import 'package:frontend/elderly/view/elderly_notifications_page.dart';
import 'package:frontend/elderly/elderly_profile/elderly_profile.dart';
import 'package:frontend/elderly/view/sos_alert_page.dart';
import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/shared/medicine/cubit/medicine_cubit.dart';
import 'package:frontend/shared/medicine/view/medicine_view.dart';
import 'package:frontend/shared/reminders/reminders.dart';
import 'package:frontend/theme/app_colors.dart';

import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'view/edit_reminders_page.dart';
import 'view/widgets/caregiver_card.dart';
import 'view/widgets/chat_card.dart';
import 'view/widgets/greetings_section.dart';
import 'view/widgets/medication_card.dart';
import '../navbar/elderly_navbar.dart';


class ElderlyDashboardPage extends StatelessWidget {
  const ElderlyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardCubit()..loadDashboard()),
        // Shared with the "Medicine" tab so both it and the "Edit Reminders"
        // screen operate on the same list of medicines.
        BlocProvider(create: (_) => MedicineCubit()..loadMedicines()),
      ],
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

  static const List<String> _titles = [
    'CareConnect',
    'Caregivers',
    'Medicine',
    'Chat',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.colorScheme.surface,
        automaticallyImplyLeading: false,
        shape: Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: AppColors.darkTeal,
            fontWeight: FontWeight.bold,
          ),
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.darkTeal, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const ElderlyNotificationsPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _DashboardHomeBody(onOpenChat: () => setState(() => _selectedIndex = 3)),
            const _CaregiversTabBody(),
            _DashboardHomeBody(
              onOpenChat: () => setState(() => _selectedIndex = 2),
              onOpenMedicine: () => setState(() => _selectedIndex = 1),
            ),
            const _MedicineTabBody(),
            const _ChatTabBody(),
            const ElderlyProfilePage(),
          ],
        ),
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
  const _DashboardHomeBody({this.onOpenChat, this.onOpenMedicine});

  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenMedicine;

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
              GreetingsSection(
                userName: state.userName,
                onSosTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SosAlertPage(),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              MedicationCard(
                medications: state.medications,
                onMarkTaken: (medication) => context
                    .read<DashboardCubit>()
                    .markMedicationTaken(medication.id),
                onViewAll: onOpenMedicine,
              ),
              const SizedBox(height: 18),
              OtherRemindersSection(reminders: state.otherReminders),
              const SizedBox(height: 18),
              AppointmentsSection(appointments: state.appointments),
              const SizedBox(height: 18),
              const _EditRemindersButton(),
              const SizedBox(height: 18),
              CaregiverCard(caregiver: state.caregiver),
              const SizedBox(height: 18),
              ChatCard(chat: state.chatPreview, onTap: onOpenChat),
            ],
          ),
        );
      },
    );
  }
}


class _CaregiversTabBody extends StatelessWidget {
  const _CaregiversTabBody();

  @override
  Widget build(BuildContext context) {
    // The elder books for themselves, so no "which elder?" step is needed.
    final selfName = context.read<DashboardCubit>().state.userName;

    return BlocProvider(
      create: (_) => CaregiverListCubit()..loadCaregivers(),
      child: CaregiverListBody(
        onCaregiverTap: (caregiver) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => CaregiverDetailsPage(
                caregiver: caregiver,
                selfBookingElderName: selfName,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MedicineTabBody extends StatelessWidget {
  const _MedicineTabBody();

  @override
  Widget build(BuildContext context) {
    // Reads the MedicineCubit provided by ElderlyDashboardPage, shared with
    // the "Edit Reminders" screen so both operate on the same medicines.
    return const MedicineView(isElderly: true);
  }
}

/// Full-width button that opens the shared "Edit Reminders" screen. Since
/// [Navigator.push] mounts the new route outside this widget's provider
/// subtree, the cubits it needs are explicitly forwarded across the route
/// boundary.
class _EditRemindersButton extends StatelessWidget {
  const _EditRemindersButton();

  @override
  Widget build(BuildContext context) {
    final dashboardCubit = context.read<DashboardCubit>();
    final medicineCubit = context.read<MedicineCubit>();

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: dashboardCubit),
                  BlocProvider.value(value: medicineCubit),
                ],
                child: const ElderlyEditRemindersPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.edit_document),
        label: const Text(
          'Edit Reminders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _ChatTabBody extends StatelessWidget {
  const _ChatTabBody();

  @override
  Widget build(BuildContext context) {
    return ChatInboxPage(
      repository: MockChatRepository.instance,
      currentUser: ChatDirectory.adib,
      showHeader: false,
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
