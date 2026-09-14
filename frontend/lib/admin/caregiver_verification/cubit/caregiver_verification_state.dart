import 'package:equatable/equatable.dart';

import 'caregiver_model.dart';
import 'caregiver_verification_filter.dart';

/// Async lifecycle of the verification list load.
enum CaregiverVerificationStatus { initial, loading, success, failure }

class CaregiverVerificationState extends Equatable {
  const CaregiverVerificationState({
    this.status = CaregiverVerificationStatus.initial,
    this.caregivers = const <CaregiverModel>[],
    this.filter = CaregiverVerificationFilter.all,
    this.searchQuery = '',
    this.errorMessage,
  });

  final CaregiverVerificationStatus status;
  final List<CaregiverModel> caregivers;
  final CaregiverVerificationFilter filter;
  final String searchQuery;
  final String? errorMessage;

  /// Caregivers after applying the active filter chip and search query,
  /// sorted by status (Pending first) then by name.
  List<CaregiverModel> get filteredCaregivers {
    final query = searchQuery.trim().toLowerCase();
    final filtered = caregivers.where((caregiver) {
      final matchesFilter = filter.matches(caregiver.status);
      final matchesSearch =
          query.isEmpty || caregiver.name.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    // Sort by status priority: Pending > Verified > Rejected, then by name
    filtered.sort((a, b) {
      if (a.status != b.status) {
        return a.status.index.compareTo(b.status.index);
      }
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  bool get isLoading => status == CaregiverVerificationStatus.loading;

  bool get isEmpty =>
      status == CaregiverVerificationStatus.success &&
          filteredCaregivers.isEmpty;

  CaregiverVerificationState copyWith({
    CaregiverVerificationStatus? status,
    List<CaregiverModel>? caregivers,
    CaregiverVerificationFilter? filter,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CaregiverVerificationState(
      status: status ?? this.status,
      caregivers: caregivers ?? this.caregivers,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    caregivers,
    filter,
    searchQuery,
    errorMessage,
  ];
}