import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../models/appointment.dart';
import 'reminder_form_field.dart';

/// Shows the "Add Appointment" / "Edit Appointment" bottom sheet. Pass
/// [existing] to pre-fill the form for editing; [onSave] is called with
/// the resulting [Appointment] once the user taps Save.
Future<void> showAppointmentFormSheet(
  BuildContext context, {
  required ValueChanged<Appointment> onSave,
  Appointment? existing,
}) {
  final doctorController = TextEditingController(text: existing?.doctorName ?? '');
  final specialtyController = TextEditingController(text: existing?.specialty ?? '');
  final locationController = TextEditingController(text: existing?.location ?? '');
  var selectedDate = DateTime.now();
  var selectedTime = TimeOfDay.now();
  var dateLabel = existing?.date;
  var timeLabel = existing?.time;

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
                  existing == null ? 'Add Appointment' : 'Edit Appointment',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                ),
                const SizedBox(height: 16),
                ReminderFormField(
                  label: 'Doctor Name',
                  controller: doctorController,
                  hint: 'e.g. Dr. Ariful Islam',
                ),
                const SizedBox(height: 14),
                ReminderFormField(
                  label: 'Specialty',
                  controller: specialtyController,
                  hint: 'e.g. Cardiologist',
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ReminderPickerField(
                        label: 'Date',
                        valueLabel: dateLabel ?? 'Select date',
                        icon: Icons.calendar_today_outlined,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: sheetContext,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              selectedDate = picked;
                              dateLabel = DateFormat('MMM d, yyyy').format(picked);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReminderPickerField(
                        label: 'Time',
                        valueLabel: timeLabel ?? 'Select time',
                        icon: Icons.access_time,
                        onTap: () async {
                          final picked = await showTimePicker(context: sheetContext, initialTime: selectedTime);
                          if (picked != null) {
                            setSheetState(() {
                              selectedTime = picked;
                              timeLabel = picked.format(sheetContext);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ReminderFormField(
                  label: 'Location',
                  controller: locationController,
                  hint: 'e.g. City Hospital',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (doctorController.text.trim().isEmpty || dateLabel == null || timeLabel == null) {
                        return;
                      }

                      onSave(
                        Appointment(
                          id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                          doctorName: doctorController.text.trim(),
                          specialty: specialtyController.text.trim(),
                          date: dateLabel!,
                          time: timeLabel!,
                          location: locationController.text.trim(),
                        ),
                      );
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
