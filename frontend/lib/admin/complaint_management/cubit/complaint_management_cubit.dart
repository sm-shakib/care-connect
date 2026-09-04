import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

import 'complaint_filter.dart';
import 'complaint_management_state.dart';
import 'complaint_model.dart';

/// Manages the complaints list: loading, searching, filtering, and
/// marking a complaint resolved.
class ComplaintManagementCubit extends Cubit<ComplaintManagementState> {
  ComplaintManagementCubit({AdminRepository? adminRepository})
      : _adminRepository = adminRepository ?? AdminRepository(),
        super(const ComplaintManagementState());

  final AdminRepository _adminRepository;

  Future<void> loadComplaints() async {
    emit(state.copyWith(status: ComplaintManagementStatus.loading));
    try {
      final statusFilter = _mapFilterToStatus(state.filter);
      final results = await _adminRepository.getComplaints(status: statusFilter);

      final complaints = results
          .map((dynamic json) => Complaint.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(
        state.copyWith(
          status: ComplaintManagementStatus.success,
          complaints: complaints,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ComplaintManagementStatus.failure,
          errorMessage: 'Unable to load complaints. Please try again.',
        ),
      );
    }
  }

  String? _mapFilterToStatus(ComplaintFilter filter) {
    switch (filter) {
      case ComplaintFilter.all:
        return null;
      case ComplaintFilter.pendingReview:
        return 'pending';
      case ComplaintFilter.resolved:
        return 'resolved';
    }
  }

  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void filterChanged(ComplaintFilter filter) {
    emit(state.copyWith(filter: filter));
    // ignore: discarded_futures
    loadComplaints();
  }

  /// Marks a complaint resolved.
  Future<void> resolve(String complaintId) async {
    try {
      final id = int.parse(complaintId.replaceFirst('CP-', ''));
      await _adminRepository.updateComplaintStatus(
        complaintId: id,
        status: 'resolved',
        adminNotes: 'Marked resolved by admin.',
      );

      final updated = state.complaints.map((complaint) {
        if (complaint.id != complaintId) return complaint;
        return complaint.copyWith(
          status: ComplaintStatus.resolved,
          statusDetail: 'Resolved',
        );
      }).toList();
      emit(state.copyWith(complaints: updated));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to resolve complaint. Please try again.',
        ),
      );
    }
  }
}
