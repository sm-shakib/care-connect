import 'package:equatable/equatable.dart';

enum BindingStatus { pending, accepted, rejected }

class BindingRequest extends Equatable {
  const BindingRequest({
    required this.id,
    required this.elderId,
    required this.familyId,
    required this.familyName,
    required this.relationship,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String elderId;
  final String familyId;
  final String familyName;
  final String relationship;
  final BindingStatus status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        elderId,
        familyId,
        familyName,
        relationship,
        status,
        createdAt,
      ];

  BindingRequest copyWith({
    BindingStatus? status,
  }) {
    return BindingRequest(
      id: id,
      elderId: elderId,
      familyId: familyId,
      familyName: familyName,
      relationship: relationship,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
