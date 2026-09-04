import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/caregiver_details/view/caregiver_details_page.dart';
import 'package:frontend/caregiver/caregiver_list/cubit/caregiver_list_cubit.dart';
import 'package:frontend/caregiver/caregiver_list/view/caregiver_list_body.dart';
import 'package:frontend/elderly/dashboard/cubit/dashboard_cubit.dart';
import 'package:frontend/elderly/dashboard/cubit/dashboard_models.dart';
import 'package:frontend/elderly/dashboard/cubit/dashboard_state.dart';
import 'package:frontend/elderly/dashboard/view/edit_reminders_page.dart';
import 'package:frontend/elderly/dashboard/view/widgets/caregiver_card.dart';
import 'package:frontend/elderly/dashboard/view/widgets/chat_card.dart';
import 'package:frontend/elderly/dashboard/view/widgets/dashboard_card_header.dart';
import 'package:frontend/elderly/dashboard/view/widgets/greetings_section.dart';
import 'package:frontend/elderly/dashboard/view/widgets/medication_card.dart';
import 'package:frontend/elderly/elderly_profile/elderly_profile.dart';
import 'package:frontend/elderly/navbar/elderly_navbar.dart';
import 'package:frontend/elderly/view/binding_requests_page.dart';
import 'package:frontend/elderly/view/elderly_notifications_page.dart';
import 'package:frontend/elderly/view/sos_alert_page.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/shared/medicine/cubit/medicine_cubit.dart';
import 'package:frontend/shared/medicine/cubit/medicine_state.dart';
import 'package:frontend/shared/medicine/data/medicine_repository.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/medicine/view/medicine_view.dart';
import 'package:frontend/shared/reminders/reminders.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';


import 'package:frontend/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';


import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/family/data/repositories/binding_repository.dart';

class ElderlyDashboardPage extends StatelessWidget {
  const ElderlyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final bindingRepository = BindingRepository(apiClient);
    final authRepository = AuthRepository();
    final medicineRepository = MedicineRepository(apiClient);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardCubit(bindingRepository)
            ..loadDashboardWithAuth(authRepository),
        ),
        BlocProvider(
          create: (_) => MedicineCubit(medicineRepository)..loadMedicines(),
        ),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationPermission();
    });
  }

  Future<void> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      
      final bool? proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _LocationRationaleDialog(),
      );

      if (proceed == true) {
        // Now trigger the actual system/browser prompt
        await Geolocator.requestPermission();
      }
    }
  }

  static List<String> _titles(BuildContext context) => [
        context.l10n.careConnectTitle,
        context.l10n.dashboardNavCaregivers,
        context.l10n.dashboardNavMedicine,
        context.l10n.dashboardNavChat,
        context.l10n.dashboardNavProfile,
      ];

  @override
  Widget build(BuildContext context) {
    final titles = _titles(context);

    return Scaffold(
      // backgroundColor: theme.colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        // backgroundColor: theme.colorScheme.surface,
        backgroundColor: const Color(0xFFFBFEFC),
        automaticallyImplyLeading: false,
        shape: const Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        title: Text(
          titles[_selectedIndex],
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
            _DashboardHomeBody(
              onOpenChat: () => setState(() => _selectedIndex = 3),
              onOpenMedicine: () => setState(() => _selectedIndex = 2),
            ),
            const _CaregiversTabBody(),
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
              state.errorMessage ?? context.l10n.genericFailureMessage,
              textAlign: TextAlign.center,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final authRepo = AuthRepository();
            await context.read<DashboardCubit>().loadDashboardWithAuth(authRepo);
          },
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
              DashboardCardHeader(
                icon: Icons.medication_outlined,
                title: context.l10n.dashboardMedicationTitle,
                trailingLabel: context.l10n.dashboardMedicationViewAll,
                onTrailingTap: onOpenMedicine,
              ),
              const SizedBox(height: 12),
              BlocBuilder<MedicineCubit, MedicineState>(
                builder: (context, medicineState) {
                  return MedicationCard(
                    medications: _nextMedicationDoses(medicineState.medicines),
                    onMarkTaken: (medication) => context
                        .read<MedicineCubit>()
                        .markTaken(medication.id, medication.time),
                  );
                },
              ),
              const SizedBox(height: 24),
              OtherRemindersSection(reminders: state.otherReminders),
              const SizedBox(height: 24),
              AppointmentsSection(appointments: state.appointments),
              const SizedBox(height: 24),
              const _EditRemindersButton(),
              const SizedBox(height: 24),
              DashboardCardHeader(
                icon: Icons.favorite_outline,
                title: context.l10n.dashboardCaregiverTitle,
              ),
              const SizedBox(height: 12),
              CaregiverCard(caregiver: state.caregiver),
              const SizedBox(height: 24),
              DashboardCardHeader(
                icon: Icons.chat_bubble_outline,
                title: context.l10n.dashboardChatTitle,
              ),
              const SizedBox(height: 12),
              ChatCard(chat: state.chatPreview, onTap: onOpenChat),
            ],
          ),
        );
      },
    );
  }
}

/// Picks the next [count] not-yet-taken doses across every medicine, in
/// chronological order for *today only* — the same medicine can appear
/// more than once if several of its doses are still due (e.g. its 8 AM and
/// 2 PM doses both remain). Doses already taken today are left out, and
/// nothing ever spills over into tomorrow's schedule.
List<Medication> _nextMedicationDoses(List<Medicine> medicines, {int count = 3}) {
  final doses = [
    for (final medicine in medicines)
      for (final time in medicine.scheduleTimes)
        if (!medicine.isDoseTaken(time)) (medicine: medicine, time: time),
  ];

  doses.sort(
    (a, b) => (_minutesSinceMidnight(a.time) ?? 24 * 60)
        .compareTo(_minutesSinceMidnight(b.time) ?? 24 * 60),
  );

  return doses
      .take(count)
      .map(
        (dose) => Medication(
          id: dose.medicine.id,
          name: dose.medicine.name,
          nameBn: dose.medicine.nameBn,
          dosage: dose.medicine.dosage,
          time: dose.time,
          isTaken: false,
        ),
      )
      .toList();
}

/// Minutes since midnight for a pre-formatted time label like "8:00 AM", or
/// `null` if it doesn't match that shape.
int? _minutesSinceMidnight(String label) {
  final match =
      RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(label.trim());
  if (match == null) return null;
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final meridiem = match.group(3)!.toUpperCase();
  if (meridiem == 'PM' && hour != 12) hour += 12;
  if (meridiem == 'AM' && hour == 12) hour = 0;
  return hour * 60 + minute;
}

class _CaregiversTabBody extends StatelessWidget {
  const _CaregiversTabBody();

  @override
  Widget build(BuildContext context) {
    // The elder books for themselves, so no "which elder?" step is needed.
    final dashboardState = context.read<DashboardCubit>().state;
    final selfName = dashboardState.userName;

    return BlocProvider(
      create: (_) => CaregiverListCubit()
        ..loadCaregivers(
          /*
          userLat: dashboardState.latitude,
          userLng: dashboardState.longitude,
          */
        ),
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
        label: Text(
          context.l10n.dashboardEditRemindersLabel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
        ? context.l10n.dashboardPendingRequestSingle
        : context.l10n.dashboardPendingRequestMultiple(count);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.paleMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
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
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const BindingRequestsPage(),
                    ),
                  ),
                ),
              );
            },
            child: Text(
              context.l10n.dashboardViewLabel,
              style: const TextStyle(
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

class _LocationRationaleDialog extends StatelessWidget {
  const _LocationRationaleDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paleMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.darkTeal,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enable Live Location',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTeal,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'To help your family monitor your safety, CareConnect needs permission to access your location while you use the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryPillButton(
              label: 'Allow Access',
              onPressed: () => Navigator.pop(context, true),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Maybe Later',
                style: TextStyle(color: AppColors.outlineLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
