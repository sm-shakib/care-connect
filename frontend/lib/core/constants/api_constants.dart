class ApiConstants {
  // Use 10.0.2.2 for Android Emulator.
  // Use your computer's IP (e.g., 192.168.x.x) if testing on a real phone.
  static const String baseUrl = 'http://10.0.2.2:8000';

  static const String elderSignup = '/elders/signup/elder';
  static const String caregiverSignup = '/signup/caregiver';
  static const String familySignup = '/families/signup/family';
  static const String login = '/login';

  // Public caregivers list
  static const String caregivers = '/caregivers';
  static String caregiverDetailPublic(int id) => '/caregivers/$id';

  // Admin
  static const String adminVerificationList = '/admin/caregivers/verification';
  static String adminCaregiverReviewDetail(int id) => '/admin/caregivers/$id';
  static String adminCaregiverUserDetail(int id) => '/admin/caregivers/user/$id';
  static String adminVerifyCaregiver(int id) => '/admin/caregivers/$id/verify';
  static String adminVerifyDocument(int id) => '/admin/caregivers/documents/$id/verify';
  static const String adminUserList = '/admin/users';
  static String adminUserStatus(int id) => '/admin/users/$id/status';
  static String adminUserDelete(int id) => '/admin/users/$id';
  static String adminElderDetail(int id) => '/admin/elders/user/$id';
  static String adminFamilyDetail(int id) => '/admin/families/user/$id';
  static const String adminBookingList = '/admin/bookings';
  static String adminBookingDetail(int id) => '/admin/bookings/$id';
  static const String adminComplaintList = '/admin/complaints';
  static String adminComplaintDetail(int id) => '/admin/complaints/$id';
  static String adminComplaintUpdate(int id) => '/admin/complaints/$id';

  // Bookings
  static const String bookings = '/bookings/';
  static String caregiverBookings(int caregiverId) => '/bookings/caregiver/$caregiverId';
  static String bookingDetail(int id) => '/bookings/$id';

  // Complaints
  static const String complaints = '/complaints/';
}
