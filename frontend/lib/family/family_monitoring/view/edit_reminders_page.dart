import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import 'package:frontend/family/cubit/family_dashboard_state.dart';
import 'package:frontend/family/models/appointment.dart';
import 'package:frontend/family/models/elder.dart';
import 'package:frontend/family/models/medication.dart';
import 'package:frontend/family/models/reminder.dart';
import 'package:frontend/theme/app_colors.dart';

class FamilyEditRemindersPage extends StatelessWidget {
  const FamilyEditRemindersPage({super.key, required this.elderId});

  final String elderId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
      builder: (context, state) {
        // Robust check for elder existence
        final elderIndex = state.elders.indexWhere((e) => e.id == elderId);
        if (elderIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Elder not found or state updated.')),
          );
        }
        
        final elder = state.elders[elderIndex];
        final cubit = context.read<FamilyDashboardCubit>();

        return Scaffold(
          backgroundColor: const Color(0xFFFBFEFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFBFEFC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Reminders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTeal,
                  ),
                ),
                Text(
                  'for ${elder.name}',
                  style: const TextStyle(fontSize: 12, color: AppColors.outlineLight),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'Medications',
                  icon: Icons.medication,
                  onAdd: () => _showMedicationForm(context, cubit, elderId),
                ),
                ...elder.medications.map((m) => _MedicationEditTile(
                  medication: m,
                  onEdit: () => _showMedicationForm(context, cubit, elderId, existing: m),
                  onDelete: () => cubit.deleteMedication(elderId, m.id),
                )),
                const SizedBox(height: 24),
                
                _SectionHeader(
                  title: 'Other Reminders',
                  icon: Icons.event_note,
                  onAdd: () => _showReminderForm(context, cubit, elderId),
                ),
                ...elder.otherReminders.map((r) => _ReminderEditTile(
                  reminder: r,
                  onEdit: () => _showReminderForm(context, cubit, elderId, existing: r),
                  onDelete: () => cubit.deleteReminder(elderId, r.id),
                )),
                const SizedBox(height: 24),
                
                _SectionHeader(
                  title: 'Appointments',
                  icon: Icons.calendar_month,
                  onAdd: () => _showAppointmentForm(context, cubit, elderId),
                ),
                ...elder.appointments.map((a) => _AppointmentEditTile(
                  appointment: a,
                  onEdit: () => _showAppointmentForm(context, cubit, elderId, existing: a),
                  onDelete: () => cubit.deleteAppointment(elderId, a.id),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMedicationForm(BuildContext context, FamilyDashboardCubit cubit, String elderId, {Medication? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final dosageController = TextEditingController(text: existing?.dosage ?? '');
    final timeController = TextEditingController(text: existing?.time ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null ? 'Add Medication' : 'Edit Medication',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 16),
            _FormInputField(label: 'Name', controller: nameController, hint: 'e.g. Metoprolol 25mg'),
            const SizedBox(height: 14),
            _FormInputField(label: 'Dosage', controller: dosageController, hint: 'e.g. 1 tablet'),
            const SizedBox(height: 14),
            _FormInputField(label: 'Time', controller: timeController, hint: 'e.g. 08:00 AM'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  final med = Medication(
                    id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    dosage: dosageController.text.trim(),
                    time: timeController.text.trim(),
                    isTaken: existing?.isTaken ?? false,
                  );
                  if (existing == null) {
                    cubit.addMedication(elderId, med);
                  } else {
                    cubit.updateMedication(elderId, med);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderForm(BuildContext context, FamilyDashboardCubit cubit, String elderId, {Reminder? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final subtitleController = TextEditingController(text: existing?.subtitle ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null ? 'Add Reminder' : 'Edit Reminder',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 16),
            _FormInputField(label: 'Title', controller: titleController, hint: 'e.g. Physical Therapy'),
            const SizedBox(height: 14),
            _FormInputField(label: 'Details', controller: subtitleController, hint: 'e.g. Session at 2:00 PM'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  final rem = Reminder(
                    id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    subtitle: subtitleController.text.trim(),
                    icon: existing?.icon ?? Icons.event_note,
                  );
                  if (existing == null) {
                    cubit.addReminder(elderId, rem);
                  } else {
                    cubit.updateReminder(elderId, rem);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentForm(BuildContext context, FamilyDashboardCubit cubit, String elderId, {Appointment? existing}) {
    final doctorController = TextEditingController(text: existing?.doctorName ?? '');
    final specialtyController = TextEditingController(text: existing?.specialty ?? '');
    final dateController = TextEditingController(text: existing?.date ?? '');
    final timeController = TextEditingController(text: existing?.time ?? '');
    final locationController = TextEditingController(text: existing?.location ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null ? 'Add Appointment' : 'Edit Appointment',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 16),
            _FormInputField(label: 'Doctor Name', controller: doctorController, hint: 'e.g. Dr. Ariful Islam'),
            const SizedBox(height: 14),
            _FormInputField(label: 'Specialty', controller: specialtyController, hint: 'e.g. Cardiologist'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _FormInputField(label: 'Date', controller: dateController, hint: 'Nov 15')),
                const SizedBox(width: 12),
                Expanded(child: _FormInputField(label: 'Time', controller: timeController, hint: '10:30 AM')),
              ],
            ),
            const SizedBox(height: 14),
            _FormInputField(label: 'Location', controller: locationController, hint: 'e.g. City Hospital'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (doctorController.text.trim().isEmpty) return;
                  final apt = Appointment(
                    id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    doctorName: doctorController.text.trim(),
                    specialty: specialtyController.text.trim(),
                    date: dateController.text.trim(),
                    time: timeController.text.trim(),
                    location: locationController.text.trim(),
                  );
                  if (existing == null) {
                    cubit.addAppointment(elderId, apt);
                  } else {
                    cubit.updateAppointment(elderId, apt);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon, required this.onAdd});
  final String title;
  final IconData icon;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.darkTeal, size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurfaceLight),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          style: TextButton.styleFrom(foregroundColor: AppColors.darkTeal),
        ),
      ],
    );
  }
}

class _MedicationEditTile extends StatelessWidget {
  const _MedicationEditTile({required this.medication, required this.onEdit, required this.onDelete});
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _EditTile(
      title: medication.name,
      subtitle: '${medication.dosage} • ${medication.time}',
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _ReminderEditTile extends StatelessWidget {
  const _ReminderEditTile({required this.reminder, required this.onEdit, required this.onDelete});
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _EditTile(
      title: reminder.title,
      subtitle: reminder.subtitle,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _AppointmentEditTile extends StatelessWidget {
  const _AppointmentEditTile({required this.appointment, required this.onEdit, required this.onDelete});
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _EditTile(
      title: appointment.doctorName,
      subtitle: '${appointment.date} • ${appointment.time}',
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _EditTile extends StatelessWidget {
  const _EditTile({required this.title, required this.subtitle, required this.onEdit, required this.onDelete});
  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariantLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariantLight, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariantLight, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _FormInputField extends StatelessWidget {
  const _FormInputField({required this.label, required this.controller, required this.hint});

  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceContainerLowLight,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariantLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariantLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkTeal, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
