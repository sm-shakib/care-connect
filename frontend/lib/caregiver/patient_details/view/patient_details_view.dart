import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/widgets/care_connect_app_bar.dart';
import 'package:frontend/theme/app_colors.dart';

import '../cubit/patient_details_cubit.dart';
import '../utils/time_ago.dart';
import '../widgets/care_reminder_tile.dart';
import '../widgets/medication_reminder_tile.dart';
import '../widgets/vital_stat_card.dart';

class PatientDetailsView extends StatelessWidget {
  const PatientDetailsView({super.key});

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
                const CareConnectAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PatientHeader(name: state.patientName),
                        const SizedBox(height: 24),
                        _VitalsRow(state: state, cubit: cubit),
                        const SizedBox(height: 28),
                        _MedicineRemindersSection(state: state, cubit: cubit),
                        const SizedBox(height: 28),
                        _OtherRemindersSection(state: state),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                _EditCarePlanButton(patientId: state.patientId),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.paleMint,
            child: const Icon(Icons.person, size: 56, color: AppColors.darkTeal),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalsRow extends StatelessWidget {
  const _VitalsRow({required this.state, required this.cubit});

  final PatientDetailsState state;
  final PatientDetailsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        VitalStatCard(
          icon: Icons.monitor_heart,
          iconColor: colorScheme.primary,
          title: 'Blood Pressure',
          //statusLabel: state.bpStatusLabel,
          valueWidget: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${state.bpSystolic}/${state.bpDiastolic} ',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    //color: colorScheme.primary,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'mmHg',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          lastCheckedText: 'Last checked: ${formatTimeAgo(state.bpCheckedAt)}',
          buttonLabel: 'Log BP',
          onButtonTap: () => _showLogBloodPressureSheet(context, cubit),
        ),
        const SizedBox(height: 14),
        VitalStatCard(
          icon: Icons.favorite,
          iconColor: colorScheme.secondary,
          title: 'Heart Rate',
          valueWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${state.heartRateBpm} ',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        //color: colorScheme.secondary,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'BPM',
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _HeartRateMiniChart(values: state.heartRateRecent, color: AppColors.darkTeal/*colorScheme.secondary*/),
            ],
          ),
          lastCheckedText: 'Last checked: ${formatTimeAgo(state.heartRateCheckedAt)}',
          buttonLabel: 'Log Heart Rate',
          onButtonTap: () => _showLogHeartRateSheet(context, cubit),
        ),
      ],
    );
  }
}

class _HeartRateMiniChart extends StatelessWidget {
  const _HeartRateMiniChart({required this.values, required this.color});

  final List<int> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final value in values) ...[
            Expanded(
              child: FractionallySizedBox(
                heightFactor: maxValue == 0 ? 0.1 : (value / maxValue).clamp(0.1, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _MedicineRemindersSection extends StatelessWidget {
  const _MedicineRemindersSection({required this.state, required this.cubit});

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
                Icon(Icons.medication, color: AppColors.darkTeal /*colorScheme.primary*/),
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
            Text(
              '${state.medicationsRemainingCount} Remaining',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                //color: colorScheme.primary,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final medication in state.medications) ...[
          MedicationReminderTile(
            medication: medication,
            onMarkTaken: () => cubit.markMedicationTaken(medication.id),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _OtherRemindersSection extends StatelessWidget {
  const _OtherRemindersSection({required this.state});

  final PatientDetailsState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < state.otherReminders.length; i++) ...[
                CareReminderTile(
                  reminder: state.otherReminders[i],
                  onTap: () {
                    // TODO: navigate to this reminder's detail/edit view.
                  },
                ),
                if (i != state.otherReminders.length - 1)
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EditCarePlanButton extends StatelessWidget {
  const _EditCarePlanButton({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: navigate to the edit-care-plan flow for this patient,
            // where reminders (medications + other reminders) can be
            // added, edited, or removed.
          },
          icon: const Icon(Icons.edit_document),
          label: const Text(
            'Edit Care Plan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.onSurface,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showLogBloodPressureSheet(BuildContext context, PatientDetailsCubit cubit) {
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
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
            const Text(
              'Log Blood Pressure',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _LargeNumberField(label: 'Systolic', controller: systolicController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LargeNumberField(label: 'Diastolic', controller: diastolicController),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final systolic = int.tryParse(systolicController.text);
                  final diastolic = int.tryParse(diastolicController.text);
                  if (systolic == null || diastolic == null) return;
                  cubit.logBloodPressure(systolic: systolic, diastolic: diastolic);
                  Navigator.of(sheetContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Reading', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showLogHeartRateSheet(BuildContext context, PatientDetailsCubit cubit) {
  final bpmController = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
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
            const Text(
              'Log Heart Rate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 16),
            _LargeNumberField(label: 'BPM', controller: bpmController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final bpm = int.tryParse(bpmController.text);
                  if (bpm == null) return;
                  cubit.logHeartRate(bpm);
                  Navigator.of(sheetContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Reading', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _LargeNumberField extends StatelessWidget {
  const _LargeNumberField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

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
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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