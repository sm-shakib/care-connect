import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/care_reminder.dart';
import 'reminder_form_field.dart';

/// Shows the "Add Reminder" / "Edit Reminder" bottom sheet. Pass
/// [existing] to pre-fill the form for editing; [onSave] is called with
/// the resulting [CareReminder] once the user taps Save.
Future<void> showCareReminderFormSheet(
  BuildContext context, {
  required ValueChanged<CareReminder> onSave,
  CareReminder? existing,
}) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final subtitleController = TextEditingController(text: existing?.subtitle ?? '');
  var selectedIcon = existing?.icon ?? careReminderIconChoices.first;
  var isAttentionNeeded = existing?.isAttentionNeeded ?? false;

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
                ReminderFormField(label: 'Title', controller: titleController, hint: 'e.g. Physical Therapy'),
                const SizedBox(height: 14),
                ReminderFormField(
                  label: 'Details',
                  controller: subtitleController,
                  hint: 'e.g. Session at 2:00 PM',
                ),
                const SizedBox(height: 14),
                const Text(
                  'Icon',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final iconChoice in careReminderIconChoices)
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
                              color: selectedIcon == iconChoice ? AppColors.darkTeal : colorScheme.outlineVariant,
                              width: selectedIcon == iconChoice ? 1.6 : 1,
                            ),
                          ),
                          child: Icon(iconChoice, color: AppColors.darkTeal),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isAttentionNeeded,
                  onChanged: (value) => setSheetState(() => isAttentionNeeded = value),
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

                      onSave(
                        CareReminder(
                          id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                          title: titleController.text.trim(),
                          subtitle: subtitleController.text.trim(),
                          icon: selectedIcon,
                          isAttentionNeeded: isAttentionNeeded,
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
