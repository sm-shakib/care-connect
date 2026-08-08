import 'package:flutter/foundation.dart';

import '../../medicine/models/medicine.dart';
import '../models/appointment.dart';
import '../models/care_reminder.dart';

/// Bundles the data and callbacks [EditRemindersView] needs, decoupling
/// it from any specific state-management solution. Each feature (family
/// monitoring, caregiver patient details, the elder's own dashboard)
/// builds one of these from its own cubit/state and rebuilds it whenever
/// that state changes.
class EditRemindersController {
  const EditRemindersController({
    required this.medicines,
    required this.onAddMedicine,
    required this.onUpdateMedicine,
    required this.onDeleteMedicine,
    required this.reminders,
    required this.onAddReminder,
    required this.onUpdateReminder,
    required this.onDeleteReminder,
    required this.appointments,
    required this.onAddAppointment,
    required this.onUpdateAppointment,
    required this.onDeleteAppointment,
  });

  final List<Medicine> medicines;
  final ValueChanged<Medicine> onAddMedicine;
  final ValueChanged<Medicine> onUpdateMedicine;
  final ValueChanged<String> onDeleteMedicine;

  final List<CareReminder> reminders;
  final ValueChanged<CareReminder> onAddReminder;
  final ValueChanged<CareReminder> onUpdateReminder;
  final ValueChanged<String> onDeleteReminder;

  final List<Appointment> appointments;
  final ValueChanged<Appointment> onAddAppointment;
  final ValueChanged<Appointment> onUpdateAppointment;
  final ValueChanged<String> onDeleteAppointment;
}
