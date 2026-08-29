class ApiConstants {
  // Use 10.0.2.2 for Android Emulator.
  // Use your computer's IP (e.g., 192.168.x.x) if testing on a real phone.
  static const String baseUrl = 'http://192.168.0.192:8000';

  static const String elderSignup = '/signup/elder';
  static const String caregiverSignup = '/signup/caregiver';
  static const String familySignup = '/signup/family';
  static const String login = '/login';

  // Public caregivers list
  static const String caregivers = '/caregivers';

  // Admin
  static const String adminVerificationList = '/admin/caregivers/verification';
  static String adminCaregiverDetail(int id) => '/admin/caregivers/$id';
  static String adminVerifyCaregiver(int id) => '/admin/caregivers/$id/verify';
  static String adminVerifyDocument(int id) => '/admin/caregivers/documents/$id/verify';

  // Bookings
  static const String bookings = '/bookings/';
  static String caregiverBookings(int caregiverId) => '/bookings/caregiver/$caregiverId';
  static String bookingDetail(int id) => '/bookings/$id';
}
