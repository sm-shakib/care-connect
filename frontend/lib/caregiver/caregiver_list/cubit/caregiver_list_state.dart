import 'package:equatable/equatable.dart';

import '../../models/caregiver.dart';

class CaregiverListState extends Equatable {
  const CaregiverListState({
    this.allCaregivers = const [],
    this.caregivers = const [],
    this.filteredCaregivers = const [],
    this.selectedFilter = 'All',
    this.searchText = '',
    this.excludedIds = const [],
  });

  final List<Caregiver> allCaregivers;
  final List<Caregiver> caregivers;
  final List<Caregiver> filteredCaregivers;
  final String selectedFilter;
  final String searchText;
  final List<String> excludedIds;

  CaregiverListState copyWith({
    List<Caregiver>? allCaregivers,
    List<Caregiver>? caregivers,
    List<Caregiver>? filteredCaregivers,
    String? selectedFilter,
    String? searchText,
    List<String>? excludedIds,
  }) {
    return CaregiverListState(
      allCaregivers: allCaregivers ?? this.allCaregivers,
      caregivers: caregivers ?? this.caregivers,
      filteredCaregivers: filteredCaregivers ?? this.filteredCaregivers,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchText: searchText ?? this.searchText,
      excludedIds: excludedIds ?? this.excludedIds,
    );
  }

  @override
  List<Object?> get props => [
    allCaregivers,
    caregivers,
    filteredCaregivers,
    selectedFilter,
    searchText,
    excludedIds,
  ];
}
