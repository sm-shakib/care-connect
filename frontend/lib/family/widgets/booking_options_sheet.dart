import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';

class BookingOptionsSheet extends StatefulWidget {
  const BookingOptionsSheet({
    required this.caregiverName,
    required this.elderName,
    required this.onConfirm,
    super.key,
  });

  final String caregiverName;
  final String elderName;
  final VoidCallback onConfirm;

  @override
  State<BookingOptionsSheet> createState() => _BookingOptionsSheetState();
}

class _BookingOptionsSheetState extends State<BookingOptionsSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<int> _selectedDays = {};
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  bool get _isFormValid =>
      _startDate != null &&
      _endDate != null &&
      _selectedDays.isNotEmpty &&
      _startTime != null &&
      _endTime != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Booking Options',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTeal,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Booking ${widget.caregiverName} for ${widget.elderName}',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          /// Period Selection
          _SectionTitle(title: 'Service Period'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  label: 'Start Date',
                  value: _startDate != null ? DateFormat('MMM d, y').format(_startDate!) : 'Select',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerTile(
                  label: 'End Date',
                  value: _endDate != null ? DateFormat('MMM d, y').format(_endDate!) : 'Select',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// Weekdays Selection
          _SectionTitle(title: 'Days of the week'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final day = index + 1;
              final isSelected = _selectedDays.contains(day);
              return ChoiceChip(
                label: Text(_dayNames[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
                selectedColor: AppColors.darkTeal.withValues(alpha: 0.15),
                checkmarkColor: AppColors.darkTeal,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.darkTeal : AppColors.onSurfaceVariantLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppColors.darkTeal : AppColors.outlineVariantLight,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          /// Timing Selection
          _SectionTitle(title: 'Daily Timing'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  label: 'Start Time',
                  value: _startTime?.format(context) ?? 'Select',
                  icon: Icons.access_time,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (picked != null) setState(() => _startTime = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerTile(
                  label: 'End Time',
                  value: _endTime?.format(context) ?? 'Select',
                  icon: Icons.access_time,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 17, minute: 0),
                    );
                    if (picked != null) setState(() => _endTime = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          PrimaryPillButton(
            label: 'Confirm Booking Request',
            onPressed: _isFormValid ? widget.onConfirm : null,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurfaceLight,
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariantLight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.darkTeal),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
