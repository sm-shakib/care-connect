import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/cubit/family_dashboard_state.dart';
import 'package:frontend/shared/reminders/reminders.dart';

/// Thin wrapper that adapts [FamilyDashboardCubit] to the shared
/// [EditRemindersView]: builds an [EditRemindersController] bound to the
/// cubit's medication/reminder/appointment methods for the given elder.
class FamilyEditRemindersPage extends StatelessWidget {
  const FamilyEditRemindersPage({super.key, required this.elderId});

  final String elderId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
      builder: (context, state) {
        final elderIndex = state.elders.indexWhere((e) => e.id == elderId);
        if (elderIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Elder not found or state updated.')),
          );
        }

        final elder = state.elders[elderIndex];
        final cubit = context.read<FamilyDashboardCubit>();

        return EditRemindersView(
          elderName: elder.name,
          controller: EditRemindersController(
            medicines: elder.medications,
            onAddMedicine: (medicine) => cubit.addMedication(elderId, medicine),
            onUpdateMedicine: (medicine) => cubit.updateMedication(elderId, medicine),
            onDeleteMedicine: (medicineId) => cubit.deleteMedication(elderId, medicineId),
            reminders: elder.otherReminders,
            onAddReminder: (reminder) => cubit.addReminder(elderId, reminder),
            onUpdateReminder: (reminder) => cubit.updateReminder(elderId, reminder),
            onDeleteReminder: (reminderId) => cubit.deleteReminder(elderId, reminderId),
            appointments: elder.appointments,
            onAddAppointment: (appointment) => cubit.addAppointment(elderId, appointment),
            onUpdateAppointment: (appointment) => cubit.updateAppointment(elderId, appointment),
            onDeleteAppointment: (appointmentId) => cubit.deleteAppointment(elderId, appointmentId),
          ),
        );
      },
    );
  }
}
