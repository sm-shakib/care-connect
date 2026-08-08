import 'package:equatable/equatable.dart';

/// A scheduled doctor's appointment for an elder.
class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
  });

  final String id;
  final String doctorName;
  final String specialty;

  /// Pre-formatted date label, e.g. "Aug 16, 2026".
  final String date;

  /// Pre-formatted time label, e.g. "10:30 AM".
  final String time;
  final String location;

  Appointment copyWith({
    String? doctorName,
    String? specialty,
    String? date,
    String? time,
    String? location,
  }) {
    return Appointment(
      id: id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [id, doctorName, specialty, date, time, location];
}
