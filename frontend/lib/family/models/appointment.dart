import 'package:equatable/equatable.dart';

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
  final String date;
  final String time;
  final String location;

  @override
  List<Object?> get props => [id, doctorName, specialty, date, time, location];
}
