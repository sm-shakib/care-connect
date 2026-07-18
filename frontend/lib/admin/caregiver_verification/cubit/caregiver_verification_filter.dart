import 'caregiver_model.dart';

/// Filter chip options shown at the top of the verification list.
enum CaregiverVerificationFilter { all, pending, verified, rejected }

extension CaregiverVerificationFilterX on CaregiverVerificationFilter {
  String get label {
    switch (this) {
      case CaregiverVerificationFilter.all:
        return 'All';
      case CaregiverVerificationFilter.pending:
        return 'Pending';
      case CaregiverVerificationFilter.verified:
        return 'Verified';
      case CaregiverVerificationFilter.rejected:
        return 'Rejected';
    }
  }

  /// Whether a caregiver with [status] should be shown under this filter.
  bool matches(VerificationStatus status) {
    switch (this) {
      case CaregiverVerificationFilter.all:
        return true;
      case CaregiverVerificationFilter.pending:
        return status == VerificationStatus.pending;
      case CaregiverVerificationFilter.verified:
        return status == VerificationStatus.verified;
      case CaregiverVerificationFilter.rejected:
        return status == VerificationStatus.rejected;
    }
  }
}