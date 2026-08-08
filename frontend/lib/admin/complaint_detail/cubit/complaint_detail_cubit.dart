import 'package:flutter_bloc/flutter_bloc.dart';

import 'complaint_detail_model.dart';
import 'complaint_detail_state.dart';

/// Manages a single complaint's detail view: loading it, resolving it,
/// and logging internal admin notes.
///
/// NOTE: [loadComplaint] looks [complaintId] up in a mock map below.
/// Wire it up to your FastAPI endpoints (e.g.
/// `GET /admin/complaints/{id}`, `PATCH /admin/complaints/{id}`, and
/// `POST /admin/complaints/{id}/notes`) when ready.
class ComplaintDetailCubit extends Cubit<ComplaintDetailState> {
  ComplaintDetailCubit({required this.complaintId})
      : super(const ComplaintDetailState());

  final String complaintId;

  Future<void> loadComplaint() async {
    emit(state.copyWith(loadStatus: ComplaintDetailLoadStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend,
      // fetching by `complaintId`.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final complaint =
          _mockComplaints[complaintId] ?? _mockComplaints.values.first;
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
    // TODO(careconnect): call `PATCH /admin/complaints/{id}` with
    // status: resolved instead of just updating local state.
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
  }

  Future<void> addInternalNote(String note) async {
    final complaint = state.complaint;
    if (complaint == null || note.trim().isEmpty) return;
    // TODO(careconnect): call `POST /admin/complaints/{id}/notes` instead
    // of just appending to local state.
    final newNote = InternalNote(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorName: 'Admin',
      note: note.trim(),
      createdAt: DateTime.now(),
    );
    final updated = complaint.copyWith(
      internalNotes: [newNote, ...complaint.internalNotes],
    );
    emit(
      state.copyWith(
        complaint: updated,
        action: ComplaintDetailAction.noteAdded,
      ),
    );
  }

  /// Clears the one-shot [ComplaintDetailState.action] after the view
  /// has reacted to it (e.g. shown a snackbar), so it doesn't refire.
  void consumeAction() {
    emit(state.copyWith(action: ComplaintDetailAction.none));
  }

  static final Map<String, ComplaintDetail> _mockComplaints = {
    'CP-1024': ComplaintDetail(
      id: 'CP-1024',
      status: ComplaintDetailStatus.pendingReview,
      statusDetail: 'Pending Review',
      filedDate: DateTime(2023, 10, 24),
      reporter: const Person(
        id: 'user-elderly-1',
        name: 'Abdur Rahim',
        role: 'Elderly',
        avatarUrl:
            'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      against: const Person(
        id: 'user-caregiver-1',
        name: 'Nasrin Akter',
        role: 'Caregiver',
        avatarUrl:
            'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      category: 'Health Safety',
      description: 'Nasrin used a dismissive tone with the patient during a '
          'home visit and left before the scheduled end time without '
          'notice. This complaint has been queued for admin review.',
      internalNotes: const [],
    ),
    'CP-1025': ComplaintDetail(
      id: 'CP-1025',
      status: ComplaintDetailStatus.pendingReview,
      statusDetail: 'Pending Review',
      filedDate: DateTime(2023, 10, 24),
      reporter: const Person(
        id: 'user-family-1',
        name: 'Jashim Uddin',
        role: 'Family Member',
        avatarUrl:
            'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      against: const Person(
        id: 'user-caregiver-2',
        name: 'Kamal Hossain',
        role: 'Caregiver',
        avatarUrl:
            'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      category: 'Late Arrival',
      description: 'Kamal used a dismissive tone with the patient during a '
          'home visit and left before the scheduled end time without '
          'notice. This complaint has been queued for admin review.',
      internalNotes: const [],
    ),
    'CP-1026': ComplaintDetail(
      id: 'CP-1026',
      status: ComplaintDetailStatus.resolved,
      statusDetail: 'Resolved',
      filedDate: DateTime(2023, 10, 23),
      reporter: const Person(
        id: 'user-family-2',
        name: 'Rummana Akter',
        role: 'Family Member',
        avatarUrl:
            'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      against: const Person(
        id: 'user-caregiver-3',
        name: 'Milon Hossain',
        role: 'Caregiver',
        avatarUrl:
            'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      category: 'Unprofessionalism',
      description: 'Milon used a dismissive tone with the patient during a '
          'home visit and left before the scheduled end time without '
          'notice. This complaint has been queued for admin review.',
      internalNotes: const [],
    ),
  };
}