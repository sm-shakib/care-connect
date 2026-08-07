import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';

/// Schedule section of the add/edit medicine form: how many times per day,
/// the start date, and a time picker per dose.
class DosageSchedule extends StatelessWidget {
  const DosageSchedule({
    required this.timesPerDay,
    required this.scheduleTimes,
    required this.startDate,
    required this.onTimesPerDayChanged,
    required this.onTimeChanged,
    required this.onStartDateChanged,
    super.key,
  });

  final int timesPerDay;
  final List<TimeOfDay?> scheduleTimes;
  final DateTime startDate;
  final ValueChanged<int> onTimesPerDayChanged;
  final void Function(int index, TimeOfDay time) onTimeChanged;
  final ValueChanged<DateTime> onStartDateChanged;

  static const _quickOptions = [1, 2, 3];

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) onStartDateChanged(picked);
  }

  Future<void> _pickTime(BuildContext context, int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: scheduleTimes[index] ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) onTimeChanged(index, picked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Times per day',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in _quickOptions)
              _CountChip(
                label: '$option',
                selected: timesPerDay == option,
                onTap: () => onTimesPerDayChanged(option),
              ),
            _CountChip(
              icon: Icons.add,
              selected: timesPerDay > _quickOptions.last,
              label: timesPerDay > _quickOptions.last ? '$timesPerDay' : null,
              onTap: () => onTimesPerDayChanged(
                timesPerDay >= _quickOptions.last ? timesPerDay + 1 : 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Start date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickStartDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant, width: 1.6),
            ),
            child: Row(
              children: [
                Icon(Icons.event, color: colorScheme.onSurfaceVariant, size: 22),
                const SizedBox(width: 10),
                Text(
                  DateFormat('MMM d, yyyy').format(startDate),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Times',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            for (var i = 0; i < timesPerDay; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _pickTime(context, i),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainerLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryContainerLight,
                      width: 1.6,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: AppColors.onPrimaryContainerLight,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dose ${i + 1}: ${scheduleTimes[i]?.format(context) ?? 'Set time'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryContainerLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i != timesPerDay - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.selected,
    required this.onTap,
    this.label,
    this.icon,
  });

  final bool selected;
  final VoidCallback onTap;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainerLight
              : colorScheme.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: icon != null && label == null
            ? Icon(
                icon,
                color: selected
                    ? AppColors.onPrimaryContainerLight
                    : colorScheme.onSurfaceVariant,
              )
            : Text(
                label ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.onPrimaryContainerLight
                      : colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}
