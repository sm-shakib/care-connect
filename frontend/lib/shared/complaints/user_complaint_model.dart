import 'package:equatable/equatable.dart';

enum UserComplaintStatus { pending, underReview, resolved, dismissed }

class UserComplaint extends Equatable {
  const UserComplaint({
    required this.id,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolutionFeedback,
    this.caregiverExplanation,
    required this.caregiverName,
    this.reporterName = '',
  });

  final String id;
  final String category;
  final String description;
  final UserComplaintStatus status;
  final DateTime createdAt;
  final String? resolutionFeedback;
  final String? caregiverExplanation;
  final String caregiverName;
  final String reporterName;

  factory UserComplaint.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    UserComplaintStatus status = UserComplaintStatus.pending;
    if (statusStr == 'under_review') {
      status = UserComplaintStatus.underReview;
    } else if (statusStr == 'resolved') {
      status = UserComplaintStatus.resolved;
    } else if (statusStr == 'dismissed') {
      status = UserComplaintStatus.dismissed;
    }

    return UserComplaint(
      id: json['id'].toString(),
      category: json['category'] as String,
      description: json['description'] as String,
      status: status,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolutionFeedback: json['resolution_feedback'] as String?,
      caregiverExplanation: json['caregiver_explanation'] as String?,
      caregiverName: json['caregiver_name'] as String? ?? 'Caregiver',
      reporterName: json['reporter_name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        description,
        status,
        createdAt,
        resolutionFeedback,
        caregiverExplanation,
        caregiverName,
        reporterName,
      ];
}
