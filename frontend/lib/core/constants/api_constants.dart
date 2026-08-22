class ApiConstants {
  // Use 10.0.2.2 for Android Emulator.
  // Use your computer's IP (e.g., 192.168.x.x) if testing on a real phone.
  static const String baseUrl = 'http://10.0.2.2:8000';

  static const String elderSignup = '/signup/elder';
  static const String caregiverSignup = '/signup/caregiver';
  static const String familySignup = '/signup/family';
  static const String login = '/login';

  // Admin
  static const String adminVerificationList = '/admin/caregivers/verification';
  static String adminCaregiverDetail(int id) => '/admin/caregivers/$id';
  static String adminVerifyCaregiver(int id) => '/admin/caregivers/$id/verify';
  static String adminVerifyDocument(int id) => '/admin/caregivers/documents/$id/verify';
}
