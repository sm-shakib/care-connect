import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/core/enums/gender.dart';
import 'package:frontend/core/widgets/care_connect_app_bar.dart';
import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/reminders/reminders.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';

import '../cubit/patient_details_cubit.dart';
import '../utils/time_ago.dart';
import '../widgets/vital_stat_card.dart';
import 'edit_reminders_page.dart';
import '../widgets/file_complaint_sheet.dart' as caregiver_sheet;

class PatientDetailsView extends StatelessWidget {
  const PatientDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFEFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(color: AppColors.outlineVariantLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.patientDetailsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        actions: [
          BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.darkTeal),
                color: const Color(0xFFFBFEFC),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (value) {
                  if (value == 'complaint') {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => caregiver_sheet.FileComplaintSheet(patientName: state.patientName),
                    );
                  } else if (value == 'complete') {
                    _confirmServiceCompletion(context, state.patientName);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'complaint',
                    child: Row(
                      children: [
                        const Icon(Icons.report_problem_outlined, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Text(context.l10n.fileComplaintLabel),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.darkTeal, size: 20),
                        const SizedBox(width: 12),
                        Text(context.l10n.markAsCompletedLabel),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
          builder: (context, state) {
            final cubit = context.read<PatientDetailsCubit>();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _PatientHeader(name: state.patientName),
                        const SizedBox(height: 20),
                        _BasicInfoSection(state: state),
                        const SizedBox(height: 24),
                        _VitalsRow(state: state, cubit: cubit),
                        const SizedBox(height: 28),
                        _MedicineRemindersSection(state: state, cubit: cubit),
                        const SizedBox(height: 28),
                        OtherRemindersSection(reminders: state.otherReminders),
                        const SizedBox(height: 28),
                        AppointmentsSection(appointments: state.appointments),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                _BottomActionButtons(
                  patientId: state.patientId,
                  patientName: state.patientName,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _confirmServiceCompletion(BuildContext context, String patientName) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(context.l10n.serviceCompletedDialogTitle),
      content: Text(context.l10n.serviceCompletedDialogContent(patientName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(context.l10n.cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.serviceCompletedSnackBar)),
            );
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.darkTeal),
          child: Text(context.l10n.yesCompleteLabel),
        ),
      ],
    ),
  );
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

/// Basic info collected during the elderly's signup — shown read-only
/// right below the profile picture/name.
class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({required this.state});

  final PatientDetailsState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dobLabel = DateFormat('d MMM yyyy').format(state.dateOfBirth!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          _BasicInfoRow(
              icon: Icons.wc_outlined,
              label: context.l10n.genderLabel,
              value: state.gender?.label(context) ?? '—'),
          _BasicInfoRow(icon: Icons.cake_outlined, label: context.l10n.dateOfBirthLabel, value: dobLabel),
          _BasicInfoRow(icon: Icons.phone_outlined, label: context.l10n.phoneNumberLabel, value: state.phone),
          _BasicInfoRow(icon: Icons.mail_outline, label: context.l10n.emailLabel, value: state.email),
          _BasicInfoRow(
            icon: Icons.location_on_outlined,
            label: context.l10n.addressLabel,
            value: state.address,
          ),
          _BasicInfoRow(
            icon: Icons.favorite_border_outlined,
            label: context.l10n.healthConditionLabel,
            value: state.healthCondition,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _BasicInfoRow extends StatelessWidget {
  const _BasicInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.25)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.darkTeal),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
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
          title: context.l10n.bloodPressureTitle,
          //statusLabel: state.bpStatusLabel,
          valueWidget: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${state.bpSystolic}/${state.bpDiastolic} ',
                  style: const TextStyle(
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
          lastCheckedText: context.l10n.lastCheckedLabel(formatTimeAgo(state.bpCheckedAt)),
          buttonLabel: context.l10n.logBpLabel,
          onButtonTap: () => _showLogBloodPressureSheet(context, cubit),
        ),
        const SizedBox(height: 14),
        VitalStatCard(
          icon: Icons.favorite,
          iconColor: colorScheme.secondary,
          title: context.l10n.heartRateTitle,
          valueWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${state.heartRateBpm} ',
                      style: const TextStyle(
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
          lastCheckedText: context.l10n.lastCheckedLabel(formatTimeAgo(state.heartRateCheckedAt)),
          buttonLabel: context.l10n.logHeartRateLabel,
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
                const Icon(Icons.medication, color: AppColors.primaryLight, size: 26),
                const SizedBox(width: 10),
                Text(
                  context.l10n.medicineRemindersTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              context.l10n.remainingCountLabel(state.medicationsRemainingCount),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.medications.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1.6,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.outlineLight),
                SizedBox(width: 12),
                Text('No medications scheduled for today.'),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1.6,
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < state.medications.length; i++) ...[
                  _MedicationTile(
                    medicine: state.medications[i],
                    onMarkTaken: () => cubit.markMedicationTaken(state.medications[i].id),
                  ),
                  if (i != state.medications.length - 1)
                    Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.medicine, required this.onMarkTaken});

  final Medicine medicine;
  final VoidCallback onMarkTaken;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          _TimeBadge(time: medicine.nextReminder),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.getName(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${medicine.dosage} ${medicine.form.label(context)}',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (medicine.isTakenToday)
            const Icon(
              Icons.check_circle,
              color: AppColors.primaryLight,
              size: 28,
            )
          else
            OutlinedButton(
              onPressed: onMarkTaken,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
                side: const BorderSide(color: AppColors.primaryLight, width: 1.4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Mark taken',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainerLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryContainerLight,
        ),
      ),
    );
  }
}

/// Chat (outlined) + Edit Reminders (filled) side by side at the bottom.
class _BottomActionButtons extends StatelessWidget {
  const _BottomActionButtons({required this.patientId, required this.patientName});

  final String patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _ChatButton(patientName: patientName),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _EditCarePlanButton(patientId: patientId),
          ),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.patientName});

  final String patientName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () async {
          final repository = MockChatRepository.instance;
          final patient = ChatDirectory.resolveOrCreateContact(patientName);
          final conversation = await repository.createDirectConversation(
            currentUser: ChatDirectory.shakibKhan,
            other: patient,
          );
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConversationPage(
                repository: repository,
                conversationId: conversation.id,
                currentUser: ChatDirectory.shakibKhan,
              ),
            ),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline, size: 20),
        label: Text(context.l10n.chatsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTeal,
          side: const BorderSide(color: AppColors.darkTeal, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _EditCarePlanButton extends StatelessWidget {
  const _EditCarePlanButton({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditRemindersPage(
                cubit: context.read<PatientDetailsCubit>(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.edit_document),
        label: Text(
          context.l10n.remindersLabel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
            Text(
              context.l10n.logBloodPressureTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _LargeNumberField(label: context.l10n.systolicLabel, controller: systolicController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LargeNumberField(label: context.l10n.diastolicLabel, controller: diastolicController),
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
                child: Text(context.l10n.saveReadingLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Text(
              context.l10n.logHeartRateTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
            ),
            const SizedBox(height: 16),
            _LargeNumberField(label: context.l10n.bpmLabel, controller: bpmController),
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
                child: Text(context.l10n.saveReadingLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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