import '../models/medication.dart';
import '../models/medicine.dart';
import 'dose_status.dart';

/// Picks the next [count] not-yet-taken doses across every medicine, in
/// chronological order for *today only* — the same medicine can appear
/// more than once if several of its doses are still due (e.g. its 8 AM and
/// 2 PM doses both remain). Doses already taken today are left out, and
/// nothing ever spills over into tomorrow's schedule.
List<Medication> nextMedicationDoses(List<Medicine> medicines, {int count = 3}) {
  final doses = [
    for (final medicine in medicines)
      for (final time in medicine.scheduleTimes)
        if (!medicine.isDoseTaken(time)) (medicine: medicine, time: time),
  ];

  doses.sort(
    (a, b) => (minutesSinceMidnight(a.time) ?? 24 * 60)
        .compareTo(minutesSinceMidnight(b.time) ?? 24 * 60),
  );

  return doses
      .take(count)
      .map(
        (dose) => Medication(
          id: dose.medicine.id,
          name: dose.medicine.name,
          nameBn: dose.medicine.nameBn,
          dosage: dose.medicine.dosage,
          time: dose.time,
          isTaken: false,
        ),
      )
      .toList();
}
