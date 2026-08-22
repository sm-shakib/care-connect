import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/admin/caregiver_review/cubit/caregiver_application_model.dart';
import 'package:frontend/admin/caregiver_review/cubit/caregiver_review_state.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

/// Manages a single caregiver application: loading its details, editing
/// admin notes, and submitting a decision.
class CaregiverReviewCubit extends Cubit<CaregiverReviewState> {
  CaregiverReviewCubit({
    required this.applicationId,
    AdminRepository? adminRepository,
  })  : _adminRepository = adminRepository ?? AdminRepository(),
        super(const CaregiverReviewState());

  final String applicationId;
  final AdminRepository _adminRepository;

  Future<void> loadApplication() async {
    emit(state.copyWith(status: CaregiverReviewStatus.loading));
    try {
      final data = await _adminRepository
          .getCaregiverApplication(int.parse(applicationId));

      final dob = DateTime.parse(data['date_of_birth'] as String);
      final age = DateTime.now().year - dob.year;

      final application = CaregiverApplication(
        id: data['id'].toString(),
        name: data['name'] as String,
        title: 'Caregiver', // Default title
        avatarUrl: data['profile_image_url'] as String? ??
            'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
        phone: data['phone'] as String,
        email: data['email'] as String? ?? '', // Need to ensure email is here
        address: data['address'] as String,
        gender: data['gender'] as String,
        age: age,
        experienceYears: data['experience_years'] as int,
        hourlyRate: (data['hourly_rate'] as num).toDouble(),
        languages: const ['English', 'Bangla'], // Default
        specializations: (data['specializations'] as String)
            .split(',')
            .map((s) => SpecializationTag(
                  label: s.trim(),
                  iconName: 'medical_services',
                  isPrimary: true,
                ))
            .toList(),
        bio: '', // Default bio
        checklist: (data['documents'] as List).map((doc) {
          return ChecklistItem(
            label: doc['document_type'] as String,
            isVerified: doc['is_verified'] as bool,
          );
        }).toList(),
        documents: (data['documents'] as List).map((doc) {
          return UploadedDocument(
            title: doc['document_type'] as String,
            subtitle: 'Verification Document',
            previewUrl: doc['document_url'] as String,
            iconName: 'description',
          );
        }).toList(),
      );

      emit(
        state.copyWith(
          status: CaregiverReviewStatus.success,
          application: application,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: CaregiverReviewStatus.failure,
          errorMessage: 'Unable to load this application. Please try again.',
        ),
      );
    }
  }

  void notesChanged(String value) {
    emit(state.copyWith(adminNotes: value));
  }

  Future<void> approve() => _submitDecision(CaregiverReviewDecision.approved);

  Future<void> requestDocs() =>
      _submitDecision(CaregiverReviewDecision.docsRequested);

  Future<void> reject() => _submitDecision(CaregiverReviewDecision.rejected);

  Future<void> _submitDecision(CaregiverReviewDecision decision) async {
    if (state.notesOverLimit) return;
    emit(
      state.copyWith(submitStatus: CaregiverReviewSubmitStatus.submitting),
    );
    try {
      final statusStr = switch (decision) {
        CaregiverReviewDecision.approved => 'verified',
        CaregiverReviewDecision.rejected => 'rejected',
        CaregiverReviewDecision.docsRequested => 'pending',
        CaregiverReviewDecision.none =>
          throw ArgumentError('Decision cannot be none'),
      };

      await _adminRepository.updateVerificationStatus(
        caregiverId: int.parse(applicationId),
        status: statusStr,
        notes: state.adminNotes.isNotEmpty ? state.adminNotes : null,
      );

      emit(
        state.copyWith(
          submitStatus: CaregiverReviewSubmitStatus.submitted,
          decision: decision,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(
          submitStatus: CaregiverReviewSubmitStatus.idle,
          errorMessage: 'Could not submit your decision. Please try again.',
        ),
      );
    }
  }
}

