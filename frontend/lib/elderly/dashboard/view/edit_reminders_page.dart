import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/medicine/cubit/medicine_cubit.dart';
import 'package:frontend/shared/medicine/cubit/medicine_state.dart';
import 'package:frontend/shared/reminders/reminders.dart';

import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

/// Thin wrapper that adapts the elder's own [DashboardCubit] (reminders,
/// appointments) and [MedicineCubit] (medications) to the shared
/// [EditRemindersView]. Both cubits are expected to already be provided
/// higher up the tree by [ElderlyDashboardPage].
class ElderlyEditRemindersPage extends StatelessWidget {
  const ElderlyEditRemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, dashboardState) {
        final dashboardCubit = context.read<DashboardCubit>();

        return BlocBuilder<MedicineCubit, MedicineState>(
          builder: (context, medicineState) {
            final medicineCubit = context.read<MedicineCubit>();

            return EditRemindersView(
              elderName: dashboardState.userName,
              controller: EditRemindersController(
                medicines: medicineState.medicines,
                onAddMedicine: medicineCubit.addMedicine,
                onUpdateMedicine: medicineCubit.updateMedicine,
                onDeleteMedicine: medicineCubit.deleteMedicine,
                reminders: dashboardState.otherReminders,
                onAddReminder: dashboardCubit.addReminder,
                onUpdateReminder: dashboardCubit.updateReminder,
                onDeleteReminder: dashboardCubit.deleteReminder,
                appointments: dashboardState.appointments,
                onAddAppointment: dashboardCubit.addAppointment,
                onUpdateAppointment: dashboardCubit.updateAppointment,
                onDeleteAppointment: dashboardCubit.deleteAppointment,
              ),
            );
          },
        );
      },
    );
  }
}
