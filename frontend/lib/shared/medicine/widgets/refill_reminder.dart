import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Refill reminder section of the add/edit medicine form: an enable switch
/// plus available-units and notify-threshold fields.
class RefillReminder extends StatelessWidget {
  const RefillReminder({
    required this.enabled,
    required this.availableUnits,
    required this.notifyThreshold,
    required this.onEnabledChanged,
    required this.onAvailableUnitsChanged,
    required this.onNotifyThresholdChanged,
    super.key,
  });

  final bool enabled;
  final int availableUnits;
  final int notifyThreshold;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onAvailableUnitsChanged;
  final ValueChanged<int> onNotifyThresholdChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Refill Reminder',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTeal,
                ),
              ),
            ),
            Switch(
              value: enabled,
              activeThumbColor: AppColors.primaryLight,
              onChanged: onEnabledChanged,
            ),
          ],
        ),
        if (enabled) ...[
          const SizedBox(height: 16),
          _NumberField(
            label: 'Available units',
            value: availableUnits,
            onChanged: onAvailableUnitsChanged,
          ),
          const SizedBox(height: 14),
          _NumberField(
            label: 'Notify threshold',
            value: notifyThreshold,
            onChanged: onNotifyThresholdChanged,
          ),
        ],
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '$value',
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.6,
          ),
        ),
      ),
      onChanged: (text) => onChanged(int.tryParse(text) ?? 0),
    );
  }
}
