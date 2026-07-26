import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isTaken = false,
  });

  final String id;
  final String name;
  final String dosage;
  final String time;
  final bool isTaken;

  @override
  List<Object?> get props => [id, name, dosage, time, isTaken];

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? time,
    bool? isTaken,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
