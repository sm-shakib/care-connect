import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/theme/app_colors.dart';

import '../cubit/patient_details_cubit.dart';
import '../models/care_reminder.dart';
import '../models/medication_reminder.dart';

class EditRemindersView extends StatelessWidget {
  const EditRemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      //backgroundColor: colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
          builder: (context, state) {
            final cubit = context.read<PatientDetailsCubit>();

            return Column(
              children: [
                _TopBar(patientName: state.patientName),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MedicationsSection(state: state, cubit: cubit),
                        const SizedBox(height: 28),
                        _OtherRemindersSection(state: state, cubit: cubit),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.patientName});

  final String patientName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            //icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            icon: Icon(Icons.arrow_back, color: AppColors.darkTeal),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Reminders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    //color: colorScheme.primary,
                    color: AppColors.darkTeal,
                  ),
                ),
                Text(
                  'for $patientName',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationsSection extends StatelessWidget {
  const _MedicationsSection({required this.state, required this.cubit});

  final PatientDetailsState state;
  final PatientDetailsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: AppColors.darkTeal),
                const SizedBox(width: 8),
                Text(
                  'Medicine Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showMedicationFormSheet(context, cubit: cubit),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(foregroundColor: AppColors.darkTeal),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.medications.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No medication reminders yet.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final medication in state.medications) ...[
            _MedicationEditTile(
              medication: medication,
              onEdit: () => _showMedicationFormSheet(
                context,
                cubit: cubit,
                existing: medication,
              ),
              onDelete: () => cubit.deleteMedication(medication.id),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _MedicationEditTile extends StatelessWidget {
  const _MedicationEditTile({
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationReminder medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scheduledLabel = DateFormat('h:mm a').format(medication.scheduledTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFEFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                Text(
                  '${medication.dose} • Scheduled: $scheduledLabel',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colorScheme.onSurfaceVariant),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: () => _confirmDelete(
              context,
              title: 'Delete this reminder?',
              message: 'This will remove "${medication.name}" from the care plan.',
              onConfirm: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherRemindersSection extends StatelessWidget {
  const _OtherRemindersSection({required this.state, required this.cubit});

  final PatientDetailsState state;
  final PatientDetailsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Other Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showCareReminderFormSheet(context, cubit: cubit),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(foregroundColor: AppColors.darkTeal),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.otherReminders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No other reminders yet.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final reminder in state.otherReminders) ...[
            _CareReminderEditTile(
              reminder: reminder,
              onEdit: () => _showCareReminderFormSheet(
                context,
                cubit: cubit,
                existing: reminder,
              ),
              onDelete: () => cubit.deleteCareReminder(reminder.id),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _CareReminderEditTile extends StatelessWidget {
  const _CareReminderEditTile({
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
  });

  final CareReminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            reminder.icon,
            color: reminder.iconColorIsError ? colorScheme.error : colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                Text(
                  reminder.subtitle,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colorScheme.onSurfaceVariant),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: () => _confirmDelete(
              context,
              title: 'Delete this reminder?',
              message: 'This will remove "${reminder.title}" from the care plan.',
              onConfirm: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

void _confirmDelete(
    BuildContext context, {
      required String title,
      required String message,
      required VoidCallback onConfirm,
    }) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(dialogContext).pop();
          },
          child: Text('Delete', style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
        ),
      ],
    ),
  );
}

Future<void> _showMedicationFormSheet(
    BuildContext context, {
      required PatientDetailsCubit cubit,
      MedicationReminder? existing,
    }) {
  final nameController = TextEditingController(text: existing?.name ?? '');
  final doseController = TextEditingController(text: existing?.dose ?? '');
  var selectedTime = existing != null
      ? TimeOfDay(hour: existing.scheduledTime.hour, minute: existing.scheduledTime.minute)
      : TimeOfDay.now();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Add Medication Reminder' : 'Edit Medication Reminder',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                ),
                const SizedBox(height: 16),
                _FormField(label: 'Name', controller: nameController, hint: 'e.g. Metoprolol 25mg'),
                const SizedBox(height: 14),
                _FormField(label: 'Dose', controller: doseController, hint: 'e.g. 1 tablet'),
                const SizedBox(height: 14),
                Text(
                  'Scheduled Time',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                ),
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final picked = await showTimePicker(context: sheetContext, initialTime: selectedTime);
                    if (picked != null) {
                      setSheetState(() => selectedTime = picked);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(sheetContext).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: AppColors.darkTeal),
                        const SizedBox(width: 10),
                        Text(selectedTime.format(sheetContext), style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty || doseController.text.trim().isEmpty) {
                        return;
                      }
                      final now = DateTime.now();
                      final scheduledTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      if (existing == null) {
                        cubit.addMedication(
                          MedicationReminder(
                            id: DateTime.now().microsecondsSinceEpoch.toString(),
                            name: nameController.text.trim(),
                            dose: doseController.text.trim(),
                            scheduledTime: scheduledTime,
                            status: MedicationStatus.upcoming,
                          ),
                        );
                      } else {
                        cubit.updateMedication(
                          existing.copyWith(
                            name: nameController.text.trim(),
                            dose: doseController.text.trim(),
                            scheduledTime: scheduledTime,
                          ),
                        );
                      }
                      Navigator.of(sheetContext).pop();
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
          );
        },
      );
    },
  );
}

const List<IconData> _careReminderIconChoices = [
  Icons.fitness_center,
  Icons.water_drop,
  Icons.event,
  Icons.directions_walk,
  Icons.restaurant,
  Icons.bedtime,
  Icons.spa,
];

Future<void> _showCareReminderFormSheet(
    BuildContext context, {
      required PatientDetailsCubit cubit,
      CareReminder? existing,
    }) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final subtitleController = TextEditingController(text: existing?.subtitle ?? '');
  var selectedIcon = existing?.icon ?? _careReminderIconChoices.first;
  var isUrgent = existing?.iconColorIsError ?? false;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final colorScheme = Theme.of(sheetContext).colorScheme;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Add Reminder' : 'Edit Reminder',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                ),
                const SizedBox(height: 16),
                _FormField(label: 'Title', controller: titleController, hint: 'e.g. Physical Therapy'),
                const SizedBox(height: 14),
                _FormField(label: 'Details', controller: subtitleController, hint: 'e.g. Session at 2:00 PM'),
                const SizedBox(height: 14),
                Text(
                  'Icon',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final iconChoice in _careReminderIconChoices)
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setSheetState(() => selectedIcon = iconChoice),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: selectedIcon == iconChoice
                                ? AppColors.darkTeal.withValues(alpha: 0.15)
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedIcon == iconChoice
                                  ? AppColors.darkTeal
                                  : colorScheme.outlineVariant,
                              width: selectedIcon == iconChoice ? 1.6 : 1,
                            ),
                          ),
                          child: Icon(iconChoice, color: AppColors.darkTeal),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isUrgent,
                  onChanged: (value) => setSheetState(() => isUrgent = value),
                  activeColor: colorScheme.error,
                  title: const Text('Show as attention-needed', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;

                      if (existing == null) {
                        cubit.addCareReminder(
                          CareReminder(
                            id: DateTime.now().microsecondsSinceEpoch.toString(),
                            title: titleController.text.trim(),
                            subtitle: subtitleController.text.trim(),
                            icon: selectedIcon,
                            iconColorIsError: isUrgent,
                          ),
                        );
                      } else {
                        cubit.updateCareReminder(
                          existing.copyWith(
                            title: titleController.text.trim(),
                            subtitle: subtitleController.text.trim(),
                            icon: selectedIcon,
                            iconColorIsError: isUrgent,
                          ),
                        );
                      }
                      Navigator.of(sheetContext).pop();
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
          );
        },
      );
    },
  );
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.controller, required this.hint});

  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            fillColor: colorScheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
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