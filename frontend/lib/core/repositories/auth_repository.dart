import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/shared/chat/data/chat_session.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  // Elder Signup
  Future<void> signupElder(Map<String, dynamic> signupData) async {
    await _apiClient.post(ApiConstants.elderSignup, data: signupData);
  }

  // Caregiver Signup
  Future<void> signupCaregiver(Map<String, dynamic> signupData) async {
    await _apiClient.post(ApiConstants.caregiverSignup, data: signupData);
  }

  // Family Signup
  Future<void> signupFamily(Map<String, dynamic> signupData) async {
    await _apiClient.post(ApiConstants.familySignup, data: signupData);
  }

  /// Uploads any file (image, PDF, DOC) via the backend to Cloudinary.
  Future<String?> uploadFile(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _apiClient.post(
        '/upload',
        data: formData,
      );

      return response.data['url'] as String;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Backend login uses form data (OAuth2 standard)
    final formData = FormData.fromMap({
      'username': email,
      'password': password,
    });

    final response = await _apiClient.post(
      ApiConstants.login,
      data: formData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    // Cast the dynamic response data to a Map
    final data = response.data as Map<String, dynamic>;

    // Save token for future use
    final token = data['access_token'] as String;
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'user_role', value: data['role'] as String);
    await _storage.write(key: 'profile_id', value: data['profile_id'].toString());

    // Whoever was signed in before is gone. `ChatSession` caches the chat
    // identity, the repository (with its conversation cache) and the open
    // socket for the app's lifetime, so without this the next account
    // inherits all three: the previous user's conversations listed in the
    // inbox, every thread titled from *their* point of view, and a socket
    // still authenticated as them. Every account switch funnels through
    // here — logging in after a logout, and the auto-login each signup
    // ends with — which the logout buttons themselves do not.
    ChatSession.reset();

    return data;
  }

  Future<int?> getProfileId() async {
    final idStr = await _storage.read(key: 'profile_id');
    return idStr != null ? int.tryParse(idStr) : null;
  }
}
