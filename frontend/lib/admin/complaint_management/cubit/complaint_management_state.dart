import 'package:equatable/equatable.dart';

import 'complaint_filter.dart';
import 'complaint_model.dart';

enum ComplaintManagementStatus { initial, loading, success, failure }

class ComplaintManagementState extends Equatable {
  const ComplaintManagementState({
    this.status = ComplaintManagementStatus.initial,
    this.complaints = const <Complaint>[],
    this.filter = ComplaintFilter.all,
    this.searchQuery = '',
    this.errorMessage,
  });

  final ComplaintManagementStatus status;
  final List<Complaint> complaints;
  final ComplaintFilter filter;
  final String searchQuery;
  final String? errorMessage;

  /// Complaints after applying the active filter chip and search query.
  /// Search matches against the complaint id or the reporter's name.
  List<Complaint> get filteredComplaints {
    final query = searchQuery.trim().toLowerCase();
    return complaints.where((complaint) {
      final matchesFilter = filter.matches(complaint.status);
      final matchesSearch = query.isEmpty ||
          complaint.id.toLowerCase().contains(query) ||
          complaint.reporterName.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  bool get isLoading => status == ComplaintManagementStatus.loading;

  bool get isEmpty =>
      status == ComplaintManagementStatus.success &&
          filteredComplaints.isEmpty;

  ComplaintManagementState copyWith({
    ComplaintManagementStatus? status,
    List<Complaint>? complaints,
    ComplaintFilter? filter,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ComplaintManagementState(
      status: status ?? this.status,
      complaints: complaints ?? this.complaints,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    complaints,
    filter,
    searchQuery,
    errorMessage,
  ];
}