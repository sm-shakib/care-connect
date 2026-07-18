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
      status: ComplaintDetailStatus.escalated,
      statusDetail: 'Pending Review',
      filedDate: DateTime(2023, 10, 24),
      reporter: const Person(
        name: 'Abdur Rahim',
        role: 'Nurse Lead',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      against: const Person(
        name: 'Nasrin Akter',
        role: 'Care Assistant',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      category: 'Health Safety',
      description:
      'Reported incident occurred during the morning shift handover. '
          'Nurse Lead Abdur Rahim noted that prescribed medication for '
          'Patient Room 402 was not documented in the electronic health '
          'record system. Upon further investigation, the morning '
          'routine appeared incomplete, creating a potential risk for '
          "the resident's schedule. This is the second recorded "
          'documentation lapse in a month for this staff member.',
      internalNotes: const [],
    ),
    'CP-1025': ComplaintDetail(
      id: 'CP-1025',
      status: ComplaintDetailStatus.inProgress,
      statusDetail: 'Under Investigation',
      filedDate: DateTime(2023, 10, 24),
      reporter: const Person(
        name: 'Jashim Uddin',
        role: 'Family Member',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      against: const Person(
        name: 'Kamal Hossain',
        role: 'Caregiver',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      category: 'Late Arrival',
      description:
      'Family member Jashim Uddin reported that caregiver Kamal '
          'Hossain arrived over 45 minutes late for a scheduled morning '
          "visit on three separate occasions this week, disrupting the "
          "patient's medication and meal schedule. Admin has requested "
          "the caregiver's shift logs for the affected dates.",
      internalNotes: const [],
    ),
    'CP-1026': ComplaintDetail(
      id: 'CP-1026',
      status: ComplaintDetailStatus.open,
      statusDetail: 'Queued',
      filedDate: DateTime(2023, 10, 23),
      reporter: const Person(
        name: 'Rummana Akter',
        role: 'Family Member',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      against: const Person(
        name: 'Milon Hossain',
        role: 'Caregiver',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      ),
      category: 'Unprofessionalism',
      description:
      'Family member Rummana Akter reported that caregiver Milon '
          'Hossain used a dismissive tone with the patient during a '
          'home visit and left before the scheduled end time without '
          'notice. This complaint has been queued for admin review.',
      internalNotes: const [],
    ),
  };
}