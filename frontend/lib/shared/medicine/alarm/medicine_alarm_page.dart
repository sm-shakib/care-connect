import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/l10n/l10n.dart';

import '../../../theme/app_colors.dart';
import '../data/medicine_repository.dart';
import 'medicine_alarm_args.dart';
import 'medicine_alarm_service.dart';

/// Full-screen "it's time to take your medicine" alarm, elder-only. Pushed
/// by [MedicineAlarmService] when a scheduled dose notification fires or is
/// tapped — including from a cold start, so this page is deliberately
/// self-contained: it renders from [args] alone and talks to the medicines
/// API directly rather than depending on a [MedicineCubit] being available
/// somewhere up the tree.
///
/// The back gesture/button is disabled — the elder must choose Taken or
/// Snooze to leave.
class MedicineAlarmPage extends StatefulWidget {
  const MedicineAlarmPage({required this.args, super.key});

  final MedicineAlarmArgs args;

  @override
  State<MedicineAlarmPage> createState() => _MedicineAlarmPageState();
}

class _MedicineAlarmPageState extends State<MedicineAlarmPage> {
  final _repository = MedicineRepository(ApiClient());
  bool _isSubmitting = false;

  Future<void> _markTaken() async {
    setState(() => _isSubmitting = true);
    try {
      await _repository.markTaken(widget.args.medicineId, widget.args.time);
      MedicineAlarmService.instance.notifyMedicineUpdated();
    } catch (e) {
      debugPrint('MedicineAlarmPage.markTaken error: $e');
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    setState(() => _isSubmitting = true);
    try {
      await MedicineAlarmService.instance.snooze(widget.args);
    } catch (e) {
      debugPrint('MedicineAlarmPage.snooze error: $e');
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkTeal,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              children: [
                const Spacer(),
                _MedicineImage(imagePath: args.imagePath),
                const SizedBox(height: 32),
                Text(
                  '${context.l10n.alarmTimeToTakeLabel} · ${args.time}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  args.getName(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  args.dosage,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _markTaken,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      context.l10n.takenStatusLabel,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainerLight,
                      foregroundColor: AppColors.onPrimaryContainerLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _snooze,
                    icon: const Icon(Icons.snooze),
                    label: Text(
                      context.l10n.snoozeMinutesLabel(
                        MedicineAlarmService.snoozeDuration.inMinutes,
                      ),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MedicineImage extends StatelessWidget {
  const _MedicineImage({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath == null
          ? const Icon(
              Icons.medication_outlined,
              color: Colors.white,
              size: 84,
            )
          : Image.file(File(imagePath!), fit: BoxFit.cover),
    );
  }
}
