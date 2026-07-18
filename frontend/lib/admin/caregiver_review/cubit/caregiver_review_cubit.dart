import 'package:flutter_bloc/flutter_bloc.dart';

import 'caregiver_application_model.dart';
import 'caregiver_review_state.dart';

/// Manages a single caregiver application: loading its details, editing
/// admin notes, and submitting a decision.
///
/// NOTE: [loadApplication] currently looks [applicationId] up in a mock
/// map below. Wire it up to your FastAPI endpoints (e.g.
/// `GET /admin/applications/{id}` and
/// `PATCH /admin/applications/{id}`) when ready.
class CaregiverReviewCubit extends Cubit<CaregiverReviewState> {
  CaregiverReviewCubit({required this.applicationId})
      : super(const CaregiverReviewState());

  final String applicationId;

  Future<void> loadApplication() async {
    emit(state.copyWith(status: CaregiverReviewStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI backend,
      // fetching by `applicationId`.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final application =
          _mockApplications[applicationId] ?? _mockApplications.values.first;
      emit(
        state.copyWith(
          status: CaregiverReviewStatus.success,
          application: application,
        ),
      );
    } catch (_) {
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
      // TODO(careconnect): call the FastAPI decision endpoint with
      // `applicationId`, `decision`, and `state.adminNotes`.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      emit(
        state.copyWith(
          submitStatus: CaregiverReviewSubmitStatus.submitted,
          decision: decision,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          submitStatus: CaregiverReviewSubmitStatus.idle,
          errorMessage: 'Could not submit your decision. Please try again.',
        ),
      );
    }
  }

  /// Mock applications keyed by id, matching the caregivers listed in
  /// [CaregiverVerificationCubit]'s mock data (ids '1'..'4').
  static const Map<String, CaregiverApplication> _mockApplications = {
    '1': CaregiverApplication(
      id: '1',
      name: 'Adib Khan',
      title: 'Dementia Care Specialist',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      phone: '+880 1712-345678',
      email: 'adib.khan@careconnect.com',
      address: 'House 12, Road 5, Dhanmondi, Dhaka',
      gender: 'Male',
      age: 29,
      experienceYears: 8,
      hourlyRate: 300,
      languages: ['Bangla (Native)', 'English (Fluent)'],
      specializations: [
        SpecializationTag(
          label: 'Dementia Care',
          iconName: 'psychology',
          isPrimary: true,
        ),
        SpecializationTag(label: 'General Care', iconName: 'medical_services'),
        SpecializationTag(label: 'First Aid/CPR', iconName: 'emergency'),
      ],
      bio:
      'Compassionate caregiver with 8 years of experience supporting '
          'elderly patients with memory-related conditions. Focused on '
          'creating calm, structured routines that preserve dignity and '
          'reduce anxiety for both patients and their families.',
      checklist: [
        ChecklistItem(label: 'National ID verified', isVerified: true),
        ChecklistItem(
          label: 'Professional Certificate reviewed',
          isVerified: true,
        ),
        ChecklistItem(label: 'Police Clearance reviewed', isVerified: false),
      ],
      documents: [
        UploadedDocument(
          title: 'National ID',
          subtitle: 'Front & Back Side',
          previewUrl:
          //'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJ3thPHNmaqs_5ZREZysUZ9Xy1y1_jfQXQKWsO3Y-tUpKK-T4ilgpQ_7A&s=10',
          iconName: 'badge',
        ),
        UploadedDocument(
          title: 'Professional Certificate',
          subtitle: 'Caregiving Diploma',
          previewUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          iconName: 'description',
        ),
      ],
    ),
    '2': CaregiverApplication(
      id: '2',
      name: 'Shakib Khan',
      title: 'Post-Op Recovery Specialist',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      phone: '+880 1812-987654',
      email: 'shakib.khan@careconnect.com',
      address: 'Flat 4B, Gulshan Avenue, Gulshan-1, Dhaka',
      gender: 'Male',
      age: 38,
      experienceYears: 12,
      hourlyRate: 500,
      languages: ['Bangla (Native)', 'English (Fluent)', 'Hindi (Basic)'],
      specializations: [
        SpecializationTag(
          label: 'Post-Op Recovery',
          iconName: 'medical_services',
          isPrimary: true,
        ),
        SpecializationTag(label: 'First Aid/CPR', iconName: 'emergency'),
        SpecializationTag(label: 'Mobility Support', iconName: 'psychology'),
      ],
      bio:
      'Registered nurse specializing in post-surgical recovery care, '
          'with 12 years across hospital and home-care settings. '
          'Experienced in wound care, pain management, and coordinating '
          'with surgeons on recovery milestones.',
      checklist: [
        ChecklistItem(label: 'National ID verified', isVerified: true),
        ChecklistItem(
          label: 'Professional Certificate reviewed',
          isVerified: true,
        ),
        ChecklistItem(label: 'Police Clearance reviewed', isVerified: true),

      ],
      documents: [
        UploadedDocument(
          title: 'National ID',
          subtitle: 'Front & Back Side',
          previewUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          iconName: 'badge',
        ),
        UploadedDocument(
          title: 'Professional Certificate',
          subtitle: 'Registered Nursing License',
          previewUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          iconName: 'description',
        ),
      ],
    ),
    '3': CaregiverApplication(
      id: '3',
      name: 'Shihab Khan',
      title: 'General Care Assistant',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      phone: '+880 1912-112233',
      email: 'shihab.khan@careconnect.com',
      address: 'House 7, Sector 11, Uttara, Dhaka',
      gender: 'Male',
      age: 24,
      experienceYears: 3,
      hourlyRate: 1000,
      languages: ['Bangla (Native)'],
      specializations: [
        SpecializationTag(
          label: 'General Care',
          iconName: 'medical_services',
          isPrimary: true,
        ),
        SpecializationTag(label: 'First Aid/CPR', iconName: 'emergency'),
      ],
      bio:
      'Early-career caregiver with 3 years of experience providing '
          'day-to-day support for elderly clients, including meal '
          'preparation, mobility assistance, and companionship.',
      checklist: [
        ChecklistItem(label: 'National ID verified', isVerified: true),
        ChecklistItem(
          label: 'Professional Certificate reviewed',
          isVerified: false,
        ),
        ChecklistItem(label: 'Police Clearance reviewed', isVerified: false),

      ],
      documents: [
        UploadedDocument(
          title: 'National ID',
          subtitle: 'Front & Back Side',
          previewUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          iconName: 'badge',
        ),
      ],
    ),
    '4': CaregiverApplication(
      id: '4',
      name: 'Mafia Messi',
      title: 'Palliative Care Specialist',
      avatarUrl:
      'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
      phone: '+880 1611-556677',
      email: 'mafia.messi@careconnect.com',
      address: 'Road 27, Banani, Dhaka',
      gender: 'Female',
      age: 45,
      experienceYears: 20,
      hourlyRate: 1000,
      languages: ['Bangla (Native)', 'English (Fluent)'],
      specializations: [
        SpecializationTag(
          label: 'Palliative Care',
          iconName: 'psychology',
          isPrimary: true,
        ),
        SpecializationTag(label: 'Dementia Care', iconName: 'medical_services'),
        SpecializationTag(label: 'First Aid/CPR', iconName: 'emergency'),
      ],
      bio:
      'Veteran caregiver with 20 years of experience in end-of-life '
          'and comfort-focused care, known for building deep trust with '
          'patients and families during difficult transitions.',
      checklist: [
        ChecklistItem(label: 'National ID verified', isVerified: true),
        ChecklistItem(
          label: 'Professional Certificate reviewed',
          isVerified: true,
        ),
        ChecklistItem(label: 'Police Clearance reviewed', isVerified: true),

      ],
      documents: [
        UploadedDocument(
          title: 'National ID',
          subtitle: 'Front & Back Side',
          previewUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          iconName: 'badge',
        ),
        UploadedDocument(
          title: 'Professional Certificate',
          subtitle: 'Palliative Care Certification',
          previewUrl:
          'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
          iconName: 'description',
        ),
      ],
    ),
  };
}