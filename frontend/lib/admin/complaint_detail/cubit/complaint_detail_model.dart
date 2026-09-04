import 'package:equatable/equatable.dart';

/// Status bucket for a complaint. Duplicated from `complaint_management`
/// (rather than imported) so this feature stays self-contained — same
/// approach used for the bottom nav bars across features.
enum ComplaintDetailStatus { pendingReview, resolved }

extension ComplaintDetailStatusX on ComplaintDetailStatus {
  String get label {
    switch (this) {
      case ComplaintDetailStatus.pendingReview:
        return 'Pending Review';
      case ComplaintDetailStatus.resolved:
        return 'Resolved';
    }
  }
}

/// A person referenced on the complaint (reporter or the person the
/// complaint is against).
class Person extends Equatable {
  const Person({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String role;
  final String avatarUrl;

  @override
  List<Object?> get props => [id, name, role, avatarUrl];
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

  factory ComplaintDetail.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final ComplaintDetailStatus status;
    final String statusDetail;

    if (statusStr == 'resolved') {
      status = ComplaintDetailStatus.resolved;
      statusDetail = 'Resolved';
    } else {
      status = ComplaintDetailStatus.pendingReview;
      statusDetail = 'Pending Review';
    }

    final List<InternalNote> internalNotes = [];
    if (json['admin_notes'] != null && (json['admin_notes'] as String).isNotEmpty) {
      internalNotes.add(InternalNote(
        id: '1',
        authorName: 'Admin',
        note: json['admin_notes'] as String,
        createdAt: DateTime.now(), // Fallback
      ));
    }

    return ComplaintDetail(
      id: 'CP-${json['id']}',
      status: status,
      statusDetail: statusDetail,
      filedDate: DateTime.parse(json['created_at'] as String),
      reporter: Person(
        id: json['reporter_id'].toString(),
        name: json['reporter_name'] as String? ?? 'Unknown',
        role: json['reporter_role'] as String? ?? 'Reporter',
        avatarUrl: '',
      ),
      against: Person(
        id: json['caregiver_id'].toString(),
        name: json['caregiver_name'] as String? ?? 'Unknown',
        role: 'Caregiver',
        avatarUrl: '',
      ),
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      internalNotes: internalNotes,
    );
  }
}
