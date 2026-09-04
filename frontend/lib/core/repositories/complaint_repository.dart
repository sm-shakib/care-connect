import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';

class ComplaintRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> fileComplaint({
    required int caregiverId,
    required String category,
    required String description,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.complaints,
      data: {
        'caregiver_id': caregiverId,
        'category': category,
        'description': description,
      },
    );
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> getMyComplaints() async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConstants.complaints}me',
    );
    return List<Map<String, dynamic>>.from(response.data!);
  }
}
