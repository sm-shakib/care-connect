class ApiConstants {
  // --- PRODUCTION (Render) ---
  static const String baseUrl = 'https://care-connect-backend-aqgr.onrender.com';

  // --- LOCAL DEVELOPMENT ---
  // Use 10.0.2.2 for Android Emulator.
  // Use computer's IP (e.g., 192.168.0.x) for physical devices.
  //static const String baseUrl = 'http://192.168.0.192:8000';


  static const String elderSignup = '/elders/signup/elder';
  static const String caregiverSignup = '/signup/caregiver';
  static const String familySignup = '/families/signup/family';
  static const String login = '/login';

  // Public caregivers list
  static const String caregivers = '/caregivers';
  static String caregiverDetailPublic(int id) => '/caregivers/$id';

  // Auth / Password Reset
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';

  // Admin
  static const String adminVerificationList = '/admin/caregivers/verification';
  static String adminCaregiverReviewDetail(int id) => '/admin/caregivers/$id';
  static String adminCaregiverUserDetail(int id) =>
      '/admin/caregivers/user/$id';
  static String adminVerifyCaregiver(int id) => '/admin/caregivers/$id/verify';
  static String adminVerifyDocument(int id) =>
      '/admin/caregivers/documents/$id/verify';
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
  static String adminComplaintNotes(int id) => '/admin/complaints/$id/notes';

  // Bookings
  static const String bookings = '/bookings/';
  static String caregiverBookings(int caregiverId) =>
      '/bookings/caregiver/$caregiverId';
  static String bookingDetail(int id) => '/bookings/$id';

  // bKash Payment
  static String bkashCreate(int bookingId) => '/bookings/$bookingId/bkash/create';
  static String bkashExecute(int bookingId) =>
      '/bookings/$bookingId/bkash/execute';

  // Complaints
  static const String complaints = '/complaints/';

  // Chat
  static const String chatMe = '/chat/me';
  static const String chatContacts = '/chat/contacts';
  static const String chatConversations = '/chat/conversations';
  static const String chatDirectConversation = '/chat/conversations/direct';
  static const String chatGroupConversation = '/chat/conversations/group';
  static String chatConversationDetail(String id) => '/chat/conversations/$id';
  static String chatMessages(String conversationId) =>
      '/chat/conversations/$conversationId/messages';
  static String chatMessage(String conversationId, String messageId) =>
      '/chat/conversations/$conversationId/messages/$messageId';
  static String chatRead(String conversationId) =>
      '/chat/conversations/$conversationId/read';
  static String chatSearch(String conversationId) =>
      '/chat/conversations/$conversationId/search';
  static String chatMedia(String conversationId) =>
      '/chat/conversations/$conversationId/media';
  static String chatMute(String conversationId) =>
      '/chat/conversations/$conversationId/mute';
  static String chatMembers(String conversationId) =>
      '/chat/conversations/$conversationId/members';
  static String chatMember(String conversationId, String memberId) =>
      '/chat/conversations/$conversationId/members/$memberId';
  static const String chatIceServers = '/chat/ice-servers';

  // --- WebRTC ---

  /// Standard ICE servers for peer-to-peer media. STUN is usually enough for
  /// same-network or simple NATs, but mobile data and corporate Wi-Fi almost
  /// always require a TURN server to relay the actual media bits.
  /// These are the static fallbacks; preferred config is fetched via
  /// [chatIceServers] endpoint.
  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  // ws:// (or wss://) equivalent of [baseUrl], for the chat/call socket.
  static String get chatSocketBase => baseUrl
      .replaceFirst('http://', 'ws://')
      .replaceFirst('https://', 'wss://');

  // Fund
  static const String fundStats = '/fund/stats';
  static const String fundDonate = '/fund/donate';
  static const String fundRequestAid = '/fund/request-aid';
  static const String fundMyDonations = '/fund/my-donations';
  static const String fundAdminDonations = '/fund/admin/donations';
  static const String fundAdminRequests = '/fund/admin/requests';
  static String fundAdminReviewRequest(int id) => '/fund/admin/requests/$id/review';
  static const String fundBkashCreate = '/fund/bkash/create';
  static String fundBkashExecute(int id) => '/fund/bkash/execute/$id';
}
