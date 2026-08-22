import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../models/medicine.dart';

/// Detail view for a single medicine: image, next reminder, dosage,
/// schedule, today's dose-by-dose status, refill status, and an edit entry
/// point. Set [onMarkTaken] to let the elder mark a specific scheduled
/// time as taken directly from here.
class MedicineDetailsView extends StatelessWidget {
  const MedicineDetailsView({
    required this.medicine,
    this.onEdit,
    this.onMarkTaken,
    super.key,
  });

  final Medicine medicine;
  final VoidCallback? onEdit;
  final ValueChanged<String>? onMarkTaken;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          width: double.infinity,
          height: screenHeight / 4,
          decoration: BoxDecoration(
            color: AppColors.primaryContainerLight.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: medicine.imagePath == null
              ? const Icon(
                  Icons.medication_outlined,
                  color: AppColors.primaryLight,
                  size: 56,
                )
              : Image.file(File(medicine.imagePath!), fit: BoxFit.cover),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            medicine.getName(context),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTeal,
            ),
          ),
        ),
        Center(
          child: Text(
            '${medicine.dosage} • ${medicine.form.label(context)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primaryContainerLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.nextReminderTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.onPrimaryContainerLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                medicine.nextReminder,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimaryContainerLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          icon: Icons.medication_outlined,
          title: context.l10n.dosageTitle,
          child: Text('${medicine.dosage} (${medicine.form.label(context)})'),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.calendar_month_outlined,
          title: context.l10n.scheduleTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.timesPerDayLabel(medicine.timesPerDay)),
              const SizedBox(height: 4),
              Text(
                context.l10n.sinceLabel(
                  DateFormat('MMM d, yyyy').format(medicine.startDate),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.untilLabel(
                  DateFormat('MMM d, yyyy').format(medicine.endDate),
                ),
              ),
              const SizedBox(height: 4),
              Text(medicine.scheduleTimes.join(', ')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.checklist_outlined,
          title: context.l10n.todaysStatusTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < medicine.scheduleTimes.length; i++) ...[
                _DoseStatusRow(
                  time: medicine.scheduleTimes[i],
                  isTaken: medicine.isDoseTaken(medicine.scheduleTimes[i]),
                  onMarkTaken: onMarkTaken == null
                      ? null
                      : () => onMarkTaken!(medicine.scheduleTimes[i]),
                ),
                if (i != medicine.scheduleTimes.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.notifications_active_outlined,
          title: context.l10n.refillReminderTitle,
          child: medicine.refillReminderEnabled
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.unitsLeftLabel(medicine.availableUnits)),
                    const SizedBox(height: 4),
                    Text(context.l10n.notifyAtLabel(medicine.notifyThreshold)),
                    if (medicine.isRefillLow) ...[
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.refillLowWarning,
                        style: const TextStyle(
                          color: AppColors.warningRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                )
              : Text(context.l10n.disabledLabel),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.onPrimaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              context.l10n.editMedicineLabel,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

/// One row of the "Today's Status" section: a scheduled time, its
/// Taken/Missed/Remaining badge, and — for the two non-taken cases — a
/// button to mark it taken right from here.
class _DoseStatusRow extends StatelessWidget {
  const _DoseStatusRow({
    required this.time,
    required this.isTaken,
    this.onMarkTaken,
  });

  final String time;
  final bool isTaken;
  final VoidCallback? onMarkTaken;

  /// A dose counts as missed once its time has passed today and it's
  /// still not taken; otherwise it's upcoming ("remaining").
  bool get _isMissed {
    if (isTaken) return false;
    final doseMinutes = _minutesSinceMidnight(time);
    if (doseMinutes == null) return false;
    final now = TimeOfDay.now();
    return doseMinutes < now.hour * 60 + now.minute;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badgeColor = isTaken
        ? Colors.green.shade700
        : _isMissed
            ? colorScheme.error
            : colorScheme.onSurfaceVariant;
    final badgeLabel = isTaken
        ? context.l10n.takenStatusLabel
        : _isMissed
            ? context.l10n.missedStatusLabel
            : context.l10n.remainingStatusLabel;

    return Row(
      children: [
        Icon(
          isTaken ? Icons.check_circle : Icons.circle_outlined,
          size: 20,
          color: badgeColor,
        ),
        const SizedBox(width: 8),
        Text(time, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            badgeLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ),
        if (!isTaken && onMarkTaken != null)
          TextButton(
            onPressed: onMarkTaken,
            child: Text(context.l10n.markTakenLabel),
          ),
      ],
    );
  }
}

/// Minutes since midnight for a pre-formatted time label like "8:00 AM", or
/// `null` if it doesn't match that shape.
int? _minutesSinceMidnight(String label) {
  final match =
      RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(label.trim());
  if (match == null) return null;
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final meridiem = match.group(3)!.toUpperCase();
  if (meridiem == 'PM' && hour != 12) hour += 12;
  if (meridiem == 'AM' && hour == 12) hour = 0;
  return hour * 60 + minute;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: AppColors.primaryLight),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
