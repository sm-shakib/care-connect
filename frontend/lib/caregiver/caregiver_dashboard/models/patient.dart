enum PatientCareStatus { active, previous }

class Patient {
  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    //required this.conditionLabel,
    //required this.conditionIcon,
    required this.status,
    required this.schedule,
    this.imageUrl = '',
    this.isUrgent = false,
  });

  final String id;
  final String name;
  final int age;
  final String location;
  //final String conditionLabel;
  //final IconData conditionIcon;
  final PatientCareStatus status;
  final bool isUrgent;
  final String imageUrl;

  /// Fixed weekly schedule label shown on patient cards.
  final String schedule;
}
