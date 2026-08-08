import 'complaint_model.dart';

/// Filter chip options shown at the top of the complaints list.
enum ComplaintFilter { all, pendingReview, resolved }

extension ComplaintFilterX on ComplaintFilter {
  String get label {
    switch (this) {
      case ComplaintFilter.all:
        return 'All';
      case ComplaintFilter.pendingReview:
        return 'Pending Review';
      case ComplaintFilter.resolved:
        return 'Resolved';
    }
  }

  /// Whether a complaint with [status] should be shown under this filter.
  bool matches(ComplaintStatus status) {
    switch (this) {
      case ComplaintFilter.all:
        return true;
      case ComplaintFilter.pendingReview:
        return status == ComplaintStatus.pendingReview;
      case ComplaintFilter.resolved:
        return status == ComplaintStatus.resolved;
    }
  }
}