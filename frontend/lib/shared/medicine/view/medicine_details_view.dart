import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../models/medicine.dart';

/// Read-only detail view for a single medicine: image, next reminder,
/// dosage, schedule, refill status, and an edit entry point.
class MedicineDetailsView extends StatelessWidget {
  const MedicineDetailsView({required this.medicine, this.onEdit, super.key});

  final Medicine medicine;
  final VoidCallback? onEdit;

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
            medicine.name,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTeal,
            ),
          ),
        ),
        Center(
          child: Text(
            '${medicine.dosage} • ${medicine.form.label}',
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
              const Text(
                'NEXT REMINDER',
                style: TextStyle(
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
          title: 'Dosage',
          child: Text('${medicine.dosage} (${medicine.form.label})'),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.calendar_month_outlined,
          title: 'Schedule',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${medicine.timesPerDay}x per day'),
              const SizedBox(height: 4),
              Text('Since ${DateFormat('MMM d, yyyy').format(medicine.startDate)}'),
              const SizedBox(height: 4),
              Text(medicine.scheduleTimes.join(', ')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.notifications_active_outlined,
          title: 'Refill Reminder',
          child: medicine.refillReminderEnabled
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${medicine.availableUnits} units left'),
                    const SizedBox(height: 4),
                    Text('Notify at ${medicine.notifyThreshold} units'),
                    if (medicine.isRefillLow) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Running low — consider ordering a refill.',
                        style: TextStyle(
                          color: AppColors.warningRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                )
              : const Text('Disabled'),
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
            child: const Text(
              'Edit Medicine',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1.6),
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
