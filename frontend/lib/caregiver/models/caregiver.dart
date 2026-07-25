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
  final List<String> languages;
  final String about;
  final String nid; // Added for verification display
  final List<String> certifications; // Added for professional details

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
    required this.languages,
    required this.about,
    this.nid = 'Not Provided',
    this.certifications = const [],
  });
}
