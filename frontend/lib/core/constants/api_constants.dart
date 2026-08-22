class ApiConstants {
  // Use 10.0.2.2 for Android Emulator. 
  // Use your computer's IP (e.g., 192.168.x.x) if testing on a real phone.
  static const String baseUrl = 'http://localhost:8000';

  static const String elderSignup = '/signup/elder';
  static const String caregiverSignup = '/signup/caregiver';
  static const String familySignup = '/signup/family';
  static const String login = '/login';
}