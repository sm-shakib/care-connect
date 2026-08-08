import 'dart:io';

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/medicine.dart';

/// Card summarizing a single medicine.
///
/// Top section is split into an image, the name/dosage/form, and the next
/// scheduled time. The bottom section shows a "Take Medicine" button, which
/// is only rendered for elderly users. Set [showTakenStatus] to show a
/// read-only "Taken" / "Not taken yet" indicator instead — used when a
/// family member or caregiver is monitoring the elder rather than acting
/// on their behalf.
class MedicineCard extends StatelessWidget {
  const MedicineCard({
    required this.medicine,
    this.isElderly = false,
    this.showTakenStatus = false,
    this.onTap,
    this.onTakeMedicine,
    super.key,
  });

  final Medicine medicine;
  final bool isElderly;
  final bool showTakenStatus;
  final VoidCallback? onTap;
  final VoidCallback? onTakeMedicine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MedicineThumbnail(imagePath: medicine.imagePath),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TimeBadge(time: medicine.nextReminder),
                        const SizedBox(height: 10),
                        Text(
                          medicine.name,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${medicine.dosage} ${medicine.form.label}',
                          style: TextStyle(
                            fontSize: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showTakenStatus) ...[
                          const SizedBox(height: 8),
                          _TakenStatus(isTaken: medicine.isTakenToday),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (isElderly) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: medicine.isTakenToday
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_circle),
                          label: const Text(
                            'Taken',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: onTakeMedicine,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.onPrimaryLight,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Take Medicine',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineThumbnail extends StatelessWidget {
  const _MedicineThumbnail({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primaryContainerLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath == null
          ? const Icon(
              Icons.medication_outlined,
              color: AppColors.primaryLight,
              size: 40,
            )
          : Image.file(File(imagePath!), fit: BoxFit.cover),
    );
  }
}

/// Read-only "Taken" / "Not taken yet" indicator: a check mark plus text.
class _TakenStatus extends StatelessWidget {
  const _TakenStatus({required this.isTaken});

  final bool isTaken;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isTaken ? Colors.green.shade700 : colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          isTaken ? 'Taken' : 'Not taken yet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainerLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryContainerLight,
        ),
      ),
    );
  }
}
