part of 'elderly_profile_cubit.dart';

class ElderlyProfileState extends Equatable {
  const ElderlyProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.gender,
    this.dateOfBirth,
    this.healthCondition = '',
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
  final String healthCondition;
  final Uint8List? profileImageBytes;

  final bool isEditing;
  final bool isSaving;
  final int editSessionId;

  ElderlyProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    Gender? gender,
    DateTime? dateOfBirth,
    String? healthCondition,
    Uint8List? profileImageBytes,
    bool? isEditing,
    bool? isSaving,
    int? editSessionId,
  }) {
    return ElderlyProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      healthCondition: healthCondition ?? this.healthCondition,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      editSessionId: editSessionId ?? this.editSessionId,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        name,
        email,
        phone,
        address,
        gender,
        dateOfBirth,
        healthCondition,
        profileImageBytes,
        isEditing,
        isSaving,
        editSessionId,
      ];
}
