import 'package:equatable/equatable.dart';

/// Status bucket for a complaint. Duplicated from `complaint_management`
/// (rather than imported) so this feature stays self-contained — same
/// approach used for the bottom nav bars across features.
enum ComplaintDetailStatus { open, inProgress, resolved, escalated }

extension ComplaintDetailStatusX on ComplaintDetailStatus {
  String get label {
    switch (this) {
      case ComplaintDetailStatus.open:
        return 'Open';
      case ComplaintDetailStatus.inProgress:
        return 'In Progress';
      case ComplaintDetailStatus.resolved:
        return 'Resolved';
      case ComplaintDetailStatus.escalated:
        return 'Escalated';
    }
  }
}

/// A person referenced on the complaint (reporter or the person the
/// complaint is against).
class Person extends Equatable {
  const Person({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  final String name;
  final String role;
  final String avatarUrl;

  @override
  List<Object?> get props => [name, role, avatarUrl];
}

/// A single internal admin note logged against a complaint.
class InternalNote extends Equatable {
  const InternalNote({
    required this.id,
    required this.authorName,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String note;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, authorName, note, createdAt];
}

/// Full detail record for a single complaint.
class ComplaintDetail extends Equatable {
  const ComplaintDetail({
    required this.id,
    required this.status,
    required this.statusDetail,
    required this.filedDate,
    required this.reporter,
    required this.against,
    required this.category,
    required this.description,
    required this.internalNotes,
  });

  final String id;
  final ComplaintDetailStatus status;
  final String statusDetail;
  final DateTime filedDate;
  final Person reporter;
  final Person against;
  final String category;
  final String description;
  final List<InternalNote> internalNotes;

  ComplaintDetail copyWith({
    ComplaintDetailStatus? status,
    String? statusDetail,
    List<InternalNote>? internalNotes,
  }) {
    return ComplaintDetail(
      id: id,
      status: status ?? this.status,
      statusDetail: statusDetail ?? this.statusDetail,
      filedDate: filedDate,
      reporter: reporter,
      against: against,
      category: category,
      description: description,
      internalNotes: internalNotes ?? this.internalNotes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    statusDetail,
    filedDate,
    reporter,
    against,
    category,
    description,
    internalNotes,
  ];
}