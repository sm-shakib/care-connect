import 'package:equatable/equatable.dart';

/// Verification lifecycle of a caregiver profile.
enum VerificationStatus { pending, verified, rejected }

/// A single caregiver row shown on the admin verification screen.
class CaregiverModel extends Equatable {
  const CaregiverModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.yearsExperience,
    required this.specialty,
    required this.hourlyRate,
    required this.status,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final int yearsExperience;
  final String specialty;
  final double hourlyRate;
  final VerificationStatus status;

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    yearsExperience,
    specialty,
    hourlyRate,
    status,
  ];
}