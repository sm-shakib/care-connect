import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/l10n/l10n.dart';

import '../../../theme/app_colors.dart';
import '../models/medicine.dart';
import '../widgets/dosage_schedule.dart';
import '../widgets/medicine_info.dart';
import '../widgets/refill_reminder.dart';

/// Add/edit medicine form. If [existing] is provided the form is
/// pre-filled and saving produces an updated copy of it.
class AddMedicineView extends StatefulWidget {
  const AddMedicineView({
    required this.onSave,
    required this.authRepository,
    this.existing,
    super.key,
  });

  final Medicine? existing;
  final AuthRepository authRepository;
  final ValueChanged<Medicine> onSave;

  @override
  State<AddMedicineView> createState() => _AddMedicineViewState();
}

class _AddMedicineViewState extends State<AddMedicineView> {
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late MedicineForm _form;
  String? _imagePath;
  late int _timesPerDay;
  late List<TimeOfDay?> _scheduleTimes;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _refillReminderEnabled;
  late int _availableUnits;
  late int _notifyThreshold;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _dosageController = TextEditingController(text: existing?.dosage ?? '');
    _form = existing?.form ?? MedicineForm.tablet;
    _imagePath = existing?.imagePath;
    _timesPerDay = existing?.timesPerDay ?? 1;
    _scheduleTimes = existing == null
        ? [null]
        : existing.scheduleTimes.map(_parseTime).toList();
    if (_scheduleTimes.length < _timesPerDay) {
      _scheduleTimes = [
        ..._scheduleTimes,
        ...List.filled(_timesPerDay - _scheduleTimes.length, null),
      ];
    }
    _startDate = existing?.startDate ?? DateTime.now();
    _endDate = existing?.endDate;
    _refillReminderEnabled = existing?.refillReminderEnabled ?? false;
    _availableUnits = existing?.availableUnits ?? 0;
    _notifyThreshold = existing?.notifyThreshold ?? 0;
  }

  /// Parses a pre-formatted time label (e.g. "8:00 AM") back into a
  /// [TimeOfDay] so an existing medicine's schedule can be edited.
  static TimeOfDay? _parseTime(String label) {
    final match =
        RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(label.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)!.toUpperCase();
    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _onTimesPerDayChanged(int value) {
    setState(() {
      _timesPerDay = value;
      if (_scheduleTimes.length < value) {
        _scheduleTimes = [
          ..._scheduleTimes,
          ...List.filled(value - _scheduleTimes.length, null),
        ];
      } else if (_scheduleTimes.length > value) {
        _scheduleTimes = _scheduleTimes.sublist(0, value);
      }
    });
  }

  void _onTimeChanged(int index, TimeOfDay time) {
    setState(() {
      _scheduleTimes[index] = time;
    });
  }

  bool get _canSave =>
      !_isSaving &&
      _nameController.text.trim().isNotEmpty &&
      _dosageController.text.trim().isNotEmpty &&
      !_scheduleTimes.contains(null) &&
      _endDate != null;

  Future<void> _save() async {
    if (!_canSave) {
      if (!_isSaving) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.fillMedicineDetailsError),
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    String? finalImagePath = _imagePath;

    // If it's a local file path, upload it first
    if (_imagePath != null && !_imagePath!.startsWith('http')) {
      try {
        final file = File(_imagePath!);
        final bytes = await file.readAsBytes();
        final filename = _imagePath!.split('/').last;
        final url = await widget.authRepository.uploadFile(bytes, filename);
        if (url != null) {
          finalImagePath = url;
        }
      } catch (e) {
        debugPrint('Error uploading medicine image: $e');
        // Continue anyway? Or show error? For now, we continue with local path
        // which might fail on other devices, but at least doesn't block save.
      }
    }

    final medicine = Medicine(
      id: widget.existing?.id ?? 'MED-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      form: _form,
      imagePath: finalImagePath,
      timesPerDay: _timesPerDay,
      scheduleTimes: _scheduleTimes
          .whereType<TimeOfDay>()
          .map((time) => time.format(context))
          .toList(),
      startDate: _startDate,
      endDate: _endDate!,
      refillReminderEnabled: _refillReminderEnabled,
      availableUnits: _availableUnits,
      notifyThreshold: _notifyThreshold,
      isTakenToday: widget.existing?.isTakenToday ?? false,
    );

    widget.onSave(medicine);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(18),
          children: [
            MedicineInfo(
              imagePath: _imagePath,
              nameController: _nameController,
              dosageController: _dosageController,
              form: _form,
              onImageSelected: (path) => setState(() => _imagePath = path),
              onFormChanged: (form) => setState(() => _form = form),
            ),
            const SizedBox(height: 24),
            DosageSchedule(
              timesPerDay: _timesPerDay,
              scheduleTimes: _scheduleTimes,
              startDate: _startDate,
              endDate: _endDate,
              onTimesPerDayChanged: _onTimesPerDayChanged,
              onTimeChanged: _onTimeChanged,
              onStartDateChanged: (date) => setState(() {
                _startDate = date;
                if (_endDate != null && _endDate!.isBefore(_startDate)) {
                  _endDate = null;
                }
              }),
              onEndDateChanged: (date) => setState(() => _endDate = date),
            ),
            const SizedBox(height: 24),
            RefillReminder(
              enabled: _refillReminderEnabled,
              availableUnits: _availableUnits,
              notifyThreshold: _notifyThreshold,
              onEnabledChanged: (value) =>
                  setState(() => _refillReminderEnabled = value),
              onAvailableUnitsChanged: (value) =>
                  setState(() => _availableUnits = value),
              onNotifyThresholdChanged: (value) =>
                  setState(() => _notifyThreshold = value),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canSave ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.onPrimaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.existing == null
                      ? context.l10n.saveMedicineLabel
                      : context.l10n.saveChangesLabel,
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        if (_isSaving)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.darkTeal),
            ),
          ),
      ],
    );
  }
}
