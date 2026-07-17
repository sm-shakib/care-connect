import 'package:equatable/equatable.dart';

/// Full profile + application data shown on the review screen.
class CaregiverApplication extends Equatable {
  const CaregiverApplication({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.phone,
    required this.email,
    required this.address,
    required this.gender,
    required this.age,
    required this.experienceYears,
    required this.hourlyRate,
    required this.languages,
    required this.specializations,
    required this.bio,
    required this.checklist,
    required this.documents,
  });

  final String id;
  final String name;
  final String title;
  final String avatarUrl;
  final String phone;
  final String email;
  final String address;
  final String gender;
  final int age;
  final int experienceYears;
  final double hourlyRate;
  final List<String> languages;
  final List<SpecializationTag> specializations;
  final String bio;
  final List<ChecklistItem> checklist;
  final List<UploadedDocument> documents;

  int get completedChecklistCount =>
      checklist.where((item) => item.isVerified).length;

  @override
  List<Object?> get props => [
    id,
    name,
    title,
    avatarUrl,
    phone,
    email,
    address,
    gender,
    age,
    experienceYears,
    hourlyRate,
    languages,
    specializations,
    bio,
    checklist,
    documents,
  ];
}

/// A specialization chip (e.g. "Dementia Care"). [isPrimary] marks the
/// highlighted/filled chip in the design (first one, tertiary-colored).
class SpecializationTag extends Equatable {
  const SpecializationTag({
    required this.label,
    required this.iconName,
    this.isPrimary = false,
  });

  final String label;
  final String iconName;
  final bool isPrimary;

  @override
  List<Object?> get props => [label, iconName, isPrimary];
}

/// A single row in the "Verification Status" checklist card.
class ChecklistItem extends Equatable {
  const ChecklistItem({
    required this.label,
    required this.isVerified,
  });

  final String label;
  final bool isVerified;

  @override
  List<Object?> get props => [label, isVerified];
}

/// A single uploaded document card (National ID, Certificate, etc).
class UploadedDocument extends Equatable {
  const UploadedDocument({
    required this.title,
    required this.subtitle,
    required this.previewUrl,
    required this.iconName,
  });

  final String title;
  final String subtitle;
  final String previewUrl;
  final String iconName;

  @override
  List<Object?> get props => [title, subtitle, previewUrl, iconName];
}