import 'complaint_model.dart';

/// Filter chip options shown at the top of the complaints list.
enum ComplaintFilter { all, open, inProgress, resolved, escalated }

extension ComplaintFilterX on ComplaintFilter {
  String get label {
    switch (this) {
      case ComplaintFilter.all:
        return 'All';
      case ComplaintFilter.open:
        return 'Open';
      case ComplaintFilter.inProgress:
        return 'In Progress';
      case ComplaintFilter.resolved:
        return 'Resolved';
      case ComplaintFilter.escalated:
        return 'Escalated';
    }
  }

  /// Whether a complaint with [status] should be shown under this filter.
  bool matches(ComplaintStatus status) {
    switch (this) {
      case ComplaintFilter.all:
        return true;
      case ComplaintFilter.open:
        return status == ComplaintStatus.open;
      case ComplaintFilter.inProgress:
        return status == ComplaintStatus.inProgress;
      case ComplaintFilter.resolved:
        return status == ComplaintStatus.resolved;
      case ComplaintFilter.escalated:
        return status == ComplaintStatus.escalated;
    }
  }
}