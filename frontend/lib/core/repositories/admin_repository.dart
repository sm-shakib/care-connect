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
    final response = await _apiClient.get(
      ApiConstants.adminVerificationList,
      queryParameters: status != null ? {'status': status} : null,
      options: options,
    );

    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<Map<String, dynamic>> getCaregiverApplication(int id) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.get(
      ApiConstants.adminCaregiverDetail(id),
      options: options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateVerificationStatus({
    required int caregiverId,
    required String status,
    String? notes,
  }) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.patch(
      ApiConstants.adminVerifyCaregiver(caregiverId),
      queryParameters: {
        'status': status,
        if (notes != null) 'notes': notes,
      },
      options: options,
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyDocument({
    required int documentId,
    required bool isVerified,
  }) async {
    final options = await _getAuthOptions();
    final response = await _apiClient.patch(
      ApiConstants.adminVerifyDocument(documentId),
      queryParameters: {'is_verified': isVerified},
      options: options,
    );

    return response.data as Map<String, dynamic>;
  }
}
