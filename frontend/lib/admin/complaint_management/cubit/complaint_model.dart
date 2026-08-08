import 'package:equatable/equatable.dart';

/// The underlying status bucket a complaint belongs to. Matches the
/// filter chips (minus "All"). Each card also shows a more specific
/// free-text [Complaint.statusDetail] (e.g. "Pending Review") for
/// nuance beyond this bucket.
enum ComplaintStatus { pendingReview, resolved }

extension ComplaintStatusX on ComplaintStatus {
  String get label {
    switch (this) {
      case ComplaintStatus.pendingReview:
        return 'Pending Review';
      case ComplaintStatus.resolved:
        return 'Resolved';
    }
  }
}

/// A single complaint/report record shown on the admin complaints list.
class Complaint extends Equatable {
  const Complaint({
    required this.id,
    required this.reportedAt,
    required this.reporterName,
    required this.againstName,
    required this.category,
    required this.status,
    required this.statusDetail,
  });

  /// Human-friendly ticket id, e.g. "CP-1024".
  final String id;
  final DateTime reportedAt;
  final String reporterName;
  final String againstName;
  final String category;
  final ComplaintStatus status;

  /// More specific status text shown on the card, e.g. "Pending Review",
  /// "Under Investigation", "Queued" — independent of the coarser
  /// [status] bucket used for filtering.
  final String statusDetail;

  Complaint copyWith({
    ComplaintStatus? status,
    String? statusDetail,
  }) {
    return Complaint(
      id: id,
      reportedAt: reportedAt,
      reporterName: reporterName,
      againstName: againstName,
      category: category,
      status: status ?? this.status,
      statusDetail: statusDetail ?? this.statusDetail,
    );
  }

  @override
  List<Object?> get props => [
    id,
    reportedAt,
    reporterName,
    againstName,
    category,
    status,
    statusDetail,
  ];
}