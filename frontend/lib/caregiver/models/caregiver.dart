class Caregiver {
  final String id;
  final String name;
  final String profession;
  final String imageUrl;
  final double rating;
  final int experience;
  final double distance;
  final int hourlyRate; // Rate in BDT per hour
  final bool isVerified;
  final List<String> specialties;
  final String about;
  final String gender; // Added for gender-specific icons

  /// Matches the AvailabilityType options collected at caregiver signup
  /// (e.g. 'Full-time', 'Part-time', 'On-call', 'Weekends Only').
  final String availabilityType;

  Caregiver({
    required this.id,
    required this.name,
    required this.profession,
    required this.imageUrl,
    required this.rating,
    required this.experience,
    required this.distance,
    required this.hourlyRate,
    required this.isVerified,
    required this.specialties,
    required this.about,
    this.gender = 'Female', // Default to Female as most caregivers are
    this.availabilityType = 'Full-time',
  });
}