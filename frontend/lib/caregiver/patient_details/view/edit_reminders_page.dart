import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/reminders/reminders.dart';

import '../cubit/patient_details_cubit.dart';

/// Thin wrapper that adapts [PatientDetailsCubit] to the shared
/// [EditRemindersView]: builds an [EditRemindersController] bound to the
/// cubit's medication/reminder/appointment methods.
class EditRemindersPage extends StatelessWidget {
  const EditRemindersPage({super.key, required this.cubit});

  /// The same [PatientDetailsCubit] instance the details page uses, so
  /// any add/edit/delete here is reflected immediately when navigating
  /// back — no separate state to keep in sync.
  final PatientDetailsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
        builder: (context, state) {
          return EditRemindersView(
            elderName: state.patientName,
            controller: EditRemindersController(
              medicines: state.medications,
              onAddMedicine: cubit.addMedication,
              onUpdateMedicine: cubit.updateMedication,
              onDeleteMedicine: cubit.deleteMedication,
              reminders: state.otherReminders,
              onAddReminder: cubit.addCareReminder,
              onUpdateReminder: cubit.updateCareReminder,
              onDeleteReminder: cubit.deleteCareReminder,
              appointments: state.appointments,
              onAddAppointment: cubit.addAppointment,
              onUpdateAppointment: cubit.updateAppointment,
              onDeleteAppointment: cubit.deleteAppointment,
            ),
          );
        },
      ),
    );
  }
}
