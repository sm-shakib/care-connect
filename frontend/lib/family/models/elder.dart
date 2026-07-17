class Elder {
  const Elder({
    required this.id,
    required this.name,
    required this.age,
    required this.relationship,
    required this.gender,
    required this.caregiverName,
    required this.hasCaregiver,
    required this.healthStatus,
    this.imageUrl = '',
  });

  final String id;
  final String name;
  final int age;
  final String relationship;
  final String gender;
  final String caregiverName;
  final bool hasCaregiver;
  final String healthStatus;
  final String imageUrl;
}