import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';

class AdminRepository {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  Future<Options> _getAuthOptions() async {
    final token = await _storage.read(key: 'access_token');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<List<Map<String, dynamic>>> getCaregiversForVerification({
    String? status,
  }) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.adminVerificationList,
      queryParameters: status != null ? {'status': status} : null,
      options: options,
    );

    return List<Map<String, dynamic>>.from(response.data!);
  }

  Future<Map<String, dynamic>> getCaregiverApplication(int id) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.adminCaregiverDetail(id),
      options: options,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> updateVerificationStatus({
    required int caregiverId,
    required String status,
    String? notes,
  }) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.adminVerifyCaregiver(caregiverId),
      queryParameters: {
        'status': status,
        if (notes != null) 'notes': notes,
      },
      options: options,
    );

    return response.data!;
  }

  Future<Map<String, dynamic>> verifyDocument({
    required int documentId,
    required bool isVerified,
  }) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.adminVerifyDocument(documentId),
      queryParameters: {'is_verified': isVerified},
      options: options,
    );

    return response.data!;
  }

  Future<List<Map<String, dynamic>>> getUsers({String? role}) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.adminUserList,
      queryParameters: role != null ? {'role': role} : null,
      options: options,
    );
    return List<Map<String, dynamic>>.from(response.data!);
  }

  Future<Map<String, dynamic>> updateUserStatus(int id, bool isActive) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.adminUserStatus(id),
      queryParameters: {'is_active': isActive},
      options: options,
    );
    return response.data!;
  }

  Future<void> deleteUser(int id) async {
    final options = await _getAuthOptions();
    await _apiClient.delete<dynamic>(
      ApiConstants.adminUserDelete(id),
      options: options,
    );
  }

  Future<Map<String, dynamic>> getElderDetail(int id) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.adminElderDetail(id),
      options: options,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getFamilyDetail(int id) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.adminFamilyDetail(id),
      options: options,
    );
    return response.data!;
  }
}
