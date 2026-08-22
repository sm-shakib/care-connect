import 'package:frontend/family/models/binding_request.dart';

class BindingRequestDto {
  final int id;
  final int familyId;
  final int elderId;
  final String relationship;
  final String status;
  final String createdAt;
  final String? familyName;
  final String? elderName;

  BindingRequestDto({
    required this.id,
    required this.familyId,
    required this.elderId,
    required this.relationship,
    required this.status,
    required this.createdAt,
    this.familyName,
    this.elderName,
  });

  factory BindingRequestDto.fromJson(Map<String, dynamic> json) {
    return BindingRequestDto(
      id: json['id'],
      familyId: json['family_id'],
      elderId: json['elder_id'],
      relationship: json['relationship'],
      status: json['status'],
      createdAt: json['created_at'],
      familyName: json['family_name'],
      elderName: json['elder_name'],
    );
  }

  BindingRequest toEntity() {
    return BindingRequest(
      id: id.toString(),
      familyId: familyId.toString(),
      elderId: elderId.toString(),
      familyName: familyName ?? 'Unknown Family',
      relationship: relationship,
      status: _parseStatus(status),
      createdAt: DateTime.parse(createdAt),
    );
  }

  static BindingStatus _parseStatus(String status) {
    switch (status) {
      case 'accepted':
        return BindingStatus.accepted;
      case 'rejected':
        return BindingStatus.rejected;
      default:
        return BindingStatus.pending;
    }
  }
}
