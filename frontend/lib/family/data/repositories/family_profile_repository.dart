import 'package:frontend/core/network/api_client.dart';

class FamilyProfileRepository {
  final ApiClient _apiClient;

  FamilyProfileRepository(this._apiClient);

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _apiClient.get('/families/me');
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _apiClient.put('/families/me', data: data);
  }
}
