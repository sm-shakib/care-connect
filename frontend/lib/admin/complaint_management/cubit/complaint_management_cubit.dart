import 'package:flutter_bloc/flutter_bloc.dart';

import 'complaint_filter.dart';
import 'complaint_management_state.dart';
import 'complaint_model.dart';

/// Manages the complaints list: loading, searching, filtering, and
/// marking a complaint resolved.
///
/// NOTE: [loadComplaints] currently returns mock data, and [resolve]
/// just updates local state. Swap both for calls into your FastAPI
/// complaints repository/endpoint when ready.
class ComplaintManagementCubit extends Cubit<ComplaintManagementState> {
  ComplaintManagementCubit() : super(const ComplaintManagementState());

  Future<void> loadComplaints() async {
    emit(state.copyWith(status: ComplaintManagementStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: ComplaintManagementStatus.success,
          complaints: _mockComplaints,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ComplaintManagementStatus.failure,
          errorMessage: 'Unable to load complaints. Please try again.',
        ),
      );
    }
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void filterChanged(ComplaintFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  /// Marks a complaint resolved locally.
  ///
  /// TODO(careconnect): call the FastAPI resolve endpoint (e.g.
  /// `PATCH /admin/complaints/{id}` with `status: resolved`) instead.
  void resolve(String complaintId) {
    final updated = state.complaints.map((complaint) {
      if (complaint.id != complaintId) return complaint;
      return complaint.copyWith(
        status: ComplaintStatus.resolved,
        statusDetail: 'Resolved',
      );
    }).toList();
    emit(state.copyWith(complaints: updated));
  }

  static final List<Complaint> _mockComplaints = [
    Complaint(
      id: 'CP-1024',
      reportedAt: DateTime(2023, 10, 24, 10, 30),
      reporterName: 'Abdur Rahim',
      againstName: 'Nasrin Akter',
      category: 'Health Safety',
      status: ComplaintStatus.escalated,
      statusDetail: 'Pending Review',
    ),
    Complaint(
      id: 'CP-1025',
      reportedAt: DateTime(2023, 10, 24, 9, 15),
      reporterName: 'Jashim Uddin',
      againstName: 'Kamal Hossain',
      category: 'Late Arrival',
      status: ComplaintStatus.inProgress,
      statusDetail: 'Under Investigation',
    ),
    Complaint(
      id: 'CP-1026',
      reportedAt: DateTime(2023, 10, 23, 16, 45),
      reporterName: 'Rummana Akter',
      againstName: 'Milon Hossain',
      category: 'Unprofessionalism',
      status: ComplaintStatus.open,
      statusDetail: 'Queued',
    ),
  ];
}