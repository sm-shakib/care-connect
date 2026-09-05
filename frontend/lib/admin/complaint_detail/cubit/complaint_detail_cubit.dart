import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

import 'complaint_detail_model.dart';
import 'complaint_detail_state.dart';

/// Manages a single complaint's detail view: loading it, resolving it,
/// and logging internal admin notes.
class ComplaintDetailCubit extends Cubit<ComplaintDetailState> {
  ComplaintDetailCubit({
    required this.complaintId,
    AdminRepository? adminRepository,
  })  : _adminRepository = adminRepository ?? AdminRepository(),
        super(const ComplaintDetailState());

  final String complaintId;
  final AdminRepository _adminRepository;

  Future<void> loadComplaint() async {
    emit(state.copyWith(loadStatus: ComplaintDetailLoadStatus.loading));
    try {
      final id = int.parse(complaintId.replaceFirst('CP-', ''));
      final data = await _adminRepository.getComplaintDetail(id);
      
      final complaint = ComplaintDetail.fromJson(data);
      
      emit(
        state.copyWith(
          loadStatus: ComplaintDetailLoadStatus.success,
          complaint: complaint,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: ComplaintDetailLoadStatus.failure,
          errorMessage: 'Unable to load this complaint. Please try again.',
        ),
      );
    }
  }

  Future<void> resolve() async {
    final complaint = state.complaint;
    if (complaint == null) return;
    
    try {
      final id = int.parse(complaintId.replaceFirst('CP-', ''));
      await _adminRepository.updateComplaintStatus(
        complaintId: id,
        status: 'resolved',
      );

      final updated = complaint.copyWith(
        status: ComplaintDetailStatus.resolved,
        statusDetail: 'Resolved',
      );
      emit(
        state.copyWith(
          complaint: updated,
          action: ComplaintDetailAction.resolved,
        ),
      );
    } catch (_) {
      // Error handled by UI via state if needed
    }
  }

  Future<void> addInternalNote(String note) async {
    final complaint = state.complaint;
    if (complaint == null || note.trim().isEmpty) return;
    
    try {
      final id = int.parse(complaintId.replaceFirst('CP-', ''));
      final data = await _adminRepository.addComplaintNote(
        complaintId: id,
        note: note.trim(),
      );

      final updatedComplaint = ComplaintDetail.fromJson(data);
      emit(
        state.copyWith(
          complaint: updatedComplaint,
          action: ComplaintDetailAction.noteAdded,
        ),
      );
    } catch (_) {
    }
  }

  Future<void> addResolutionFeedback(String feedback) async {
    final complaint = state.complaint;
    if (complaint == null || feedback.trim().isEmpty) return;

    try {
      final id = int.parse(complaintId.replaceFirst('CP-', ''));
      final data = await _adminRepository.updateComplaintStatus(
        complaintId: id,
        status: 'resolved',
        resolutionFeedback: feedback.trim(),
      );

      final updatedComplaint = ComplaintDetail.fromJson(data);
      emit(
        state.copyWith(
          complaint: updatedComplaint,
          action: ComplaintDetailAction.resolved,
        ),
      );
    } catch (_) {
    }
  }

  /// Clears the one-shot [ComplaintDetailState.action] after the view
  /// has reacted to it (e.g. shown a snackbar), so it doesn't refire.
  void consumeAction() {
    emit(state.copyWith(action: ComplaintDetailAction.none));
  }
}
