import 'package:equatable/equatable.dart';

import '../../models/caregiver.dart';

class CaregiverListState extends Equatable {
  const CaregiverListState({
    this.caregivers = const [],
    this.filteredCaregivers = const [],
    this.selectedFilter = 'All',
    this.searchText = '',
  });

  final List<Caregiver> caregivers;
  final List<Caregiver> filteredCaregivers;
  final String selectedFilter;
  final String searchText;

  CaregiverListState copyWith({
    List<Caregiver>? caregivers,
    List<Caregiver>? filteredCaregivers,
    String? selectedFilter,
    String? searchText,
  }) {
    return CaregiverListState(
      caregivers: caregivers ?? this.caregivers,
      filteredCaregivers:
      filteredCaregivers ?? this.filteredCaregivers,
      selectedFilter:
      selectedFilter ?? this.selectedFilter,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    caregivers,
    filteredCaregivers,
    selectedFilter,
    searchText,
  ];
}