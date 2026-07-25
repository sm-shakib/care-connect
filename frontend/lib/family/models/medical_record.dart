import 'package:equatable/equatable.dart';

class MedicalRecord extends Equatable {
  const MedicalRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.doctorNote,
    required this.healthStatus,
  });

  final String id;
  final String title;
  final String date;
  final String doctorNote;
  final String healthStatus;

  @override
  List<Object?> get props => [id, title, date, doctorNote, healthStatus];
}
