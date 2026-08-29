part of 'family_profile_cubit.dart';

enum FamilyProfileStatus { initial, loading, success, failure }

class FamilyProfileState extends Equatable {
  const FamilyProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.gender,
    this.dateOfBirth,
    this.profileImageBytes,
    this.profileImageUrl = '',
    this.isEditing = false,
    this.isSaving = false,
    this.editSessionId = 0,
    this.status = FamilyProfileStatus.initial,
    this.errorMessage,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final Uint8List? profileImageBytes;
  final String profileImageUrl;

  final bool isEditing;
  final bool isSaving;
  final int editSessionId;
  final FamilyProfileStatus status;
  final String? errorMessage;

  FamilyProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    Gender? gender,
    DateTime? dateOfBirth,
    Uint8List? profileImageBytes,
    String? profileImageUrl,
    bool? isEditing,
    bool? isSaving,
    int? editSessionId,
    FamilyProfileStatus? status,
    String? errorMessage,
  }) {
    return FamilyProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      editSessionId: editSessionId ?? this.editSessionId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    address,
    gender,
    dateOfBirth,
    profileImageBytes,
    profileImageUrl,
    isEditing,
    isSaving,
    editSessionId,
    status,
    errorMessage,
  ];
}
