import '../models/medication.dart';
import '../models/medicine.dart';
import 'dose_status.dart';

/// Picks the doses across every medicine in chronological order for
/// *today only*. If [pendingOnly] is true, it only returns doses not
/// yet taken. If false (default), it returns all doses for today.
List<Medication> nextMedicationDoses(
  List<Medicine> medicines, {
  int count = 3,
  bool pendingOnly = false,
}) {
  final List<Medication> allDoses = [];

  for (final medicine in medicines) {
    for (final time in medicine.scheduleTimes) {
      final isTaken = medicine.isDoseTaken(time);
      if (!pendingOnly || !isTaken) {
        allDoses.add(
          Medication(
            id: medicine.id,
            name: medicine.name,
            nameBn: medicine.nameBn,
            dosage: medicine.dosage,
            time: time,
            isTaken: isTaken,
          ),
        );
      }
    }
  }

  // Sort chronologically
  allDoses.sort((a, b) {
    final aMins = minutesSinceMidnight(a.time) ?? 0;
    final bMins = minutesSinceMidnight(b.time) ?? 0;
    return aMins.compareTo(bMins);
  });

  if (allDoses.length <= count) {
    return allDoses;
  }

  // If we have more than 'count' doses, try to show a mix of recently taken
  // and upcoming ones.
  // For now, let's just return the first 'count' ones if they are all pending,
  // or the 'count' closest to "now".
  // Simplified: just take the first 'count' for now to match previous behavior
  // but ensure it's not empty if there are any.
  return allDoses.take(count).toList();
}
