import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';

import '../../../theme/app_colors.dart';
import '../../medicine/models/medicine.dart';
import '../../medicine/view/add_medicine_page.dart';
import '../controller/edit_reminders_controller.dart';
import '../widgets/appointment_form_sheet.dart';
import '../widgets/care_reminder_form_sheet.dart';
import '../widgets/reminder_edit_tile.dart';
import '../widgets/section_header.dart';

/// Shared "Edit Reminders" screen: manages an elder's medications (via the
/// existing [AddMedicinePage] from `shared/medicine`), other reminders, and
/// appointments. Pure UI driven entirely by [controller] — callers own the
/// underlying data/persistence (a family/caregiver/elder cubit) and rebuild
/// this screen whenever that state changes.
class EditRemindersView extends StatelessWidget {
  const EditRemindersView({
    required this.elderName,
    required this.controller,
    super.key,
  });

  final String elderName;
  final EditRemindersController controller;

  Future<void> _openMedicineForm(BuildContext context, {Medicine? existing}) async {
    final saved = await Navigator.push<Medicine>(
      context,
      MaterialPageRoute(builder: (_) => AddMedicinePage(existing: existing)),
    );
    if (saved == null) return;
    if (existing == null) {
      controller.onAddMedicine(saved);
    } else {
      controller.onUpdateMedicine(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFEFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.editRemindersTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTeal,
              ),
            ),
            Text(
              context.l10n.editRemindersForLabel(elderName),
              style:
                  const TextStyle(fontSize: 12, color: AppColors.outlineLight),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RemindersSectionHeader(
                title: context.l10n.medicationsTitle,
                icon: Icons.medication,
                onAdd: () => _openMedicineForm(context),
              ),
              const SizedBox(height: 12),
              if (controller.medicines.isEmpty)
                _EmptySectionHint(text: context.l10n.noMedicationsYet)
              else
                for (final medicine in controller.medicines) ...[
                  ReminderEditTile(
                    title: medicine.getName(context),
                    subtitle: '${medicine.dosage} • ${medicine.nextReminder}',
                    onEdit: () =>
                        _openMedicineForm(context, existing: medicine),
                    onDelete: () => controller.onDeleteMedicine(medicine.id),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 24),
              RemindersSectionHeader(
                title: context.l10n.otherRemindersTitle,
                icon: Icons.event_note,
                onAdd: () => showCareReminderFormSheet(context,
                    onSave: controller.onAddReminder),
              ),
              const SizedBox(height: 12),
              if (controller.reminders.isEmpty)
                _EmptySectionHint(text: context.l10n.noOtherRemindersYet)
              else
                for (final reminder in controller.reminders) ...[
                  ReminderEditTile(
                    title: reminder.title,
                    subtitle: reminder.subtitle,
                    leadingIcon: reminder.icon,
                    onEdit: () => showCareReminderFormSheet(
                      context,
                      existing: reminder,
                      onSave: controller.onUpdateReminder,
                    ),
                    onDelete: () => controller.onDeleteReminder(reminder.id),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 24),
              RemindersSectionHeader(
                title: context.l10n.upcomingAppointmentsTitle,
                icon: Icons.calendar_month,
                onAdd: () => showAppointmentFormSheet(context,
                    onSave: controller.onAddAppointment),
              ),
              const SizedBox(height: 12),
              if (controller.appointments.isEmpty)
                _EmptySectionHint(text: context.l10n.noAppointmentsScheduled)
              else
                for (final appointment in controller.appointments) ...[
                  ReminderEditTile(
                    title: appointment.doctorName,
                    subtitle: '${appointment.date} • ${appointment.time}',
                    onEdit: () => showAppointmentFormSheet(
                      context,
                      existing: appointment,
                      onSave: controller.onUpdateAppointment,
                    ),
                    onDelete: () => controller.onDeleteAppointment(appointment.id),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySectionHint extends StatelessWidget {
  const _EmptySectionHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
