import 'package:equatable/equatable.dart';

import '../models/patient.dart';

class CaregiverDashboardState extends Equatable {
  const CaregiverDashboardState({
    this.allPatients = const [],
    this.searchQuery = '',
  });

  final List<Patient> allPatients;
  final String searchQuery;

  List<Patient> get activePatients => allPatients
      .where((patient) => patient.status == PatientCareStatus.active)
      .toList();

  List<Patient> get previousPatients => allPatients
      .where((patient) => patient.status == PatientCareStatus.previous)
      .toList();

  List<Patient> get filteredActivePatients => _filter(activePatients);

  List<Patient> get filteredPreviousPatients => _filter(previousPatients);

  List<Patient> _filter(List<Patient> patients) {
    if (searchQuery.trim().isEmpty) return patients;
    final query = searchQuery.toLowerCase();
    return patients
        .where((patient) => patient.name.toLowerCase().contains(query))
        .toList();
  }

  CaregiverDashboardState copyWith({
    List<Patient>? allPatients,
    String? searchQuery,
  }) {
    return CaregiverDashboardState(
      allPatients: allPatients ?? this.allPatients,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allPatients, searchQuery];
}