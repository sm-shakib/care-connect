part of 'family_profile_cubit.dart';

class FamilyProfileState extends Equatable {
  const FamilyProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.gender,
    this.dateOfBirth,
    this.profileImageBytes,
    this.isEditing = false,
    this.isSaving = false,
    this.editSessionId = 0,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final Uint8List? profileImageBytes;

  final bool isEditing;
  final bool isSaving;
  final int editSessionId;

  FamilyProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    Gender? gender,
    DateTime? dateOfBirth,
    Uint8List? profileImageBytes,
    bool? isEditing,
    bool? isSaving,
    int? editSessionId,
  }) {
    return FamilyProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      editSessionId: editSessionId ?? this.editSessionId,
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
    isEditing,
    isSaving,
    editSessionId,
  ];
}
