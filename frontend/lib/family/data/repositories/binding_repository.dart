import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/family/data/models/binding_request_dto.dart';
import 'package:frontend/family/models/binding_request.dart';

class BindingRepository {
  final ApiClient _apiClient;

  BindingRepository(this._apiClient);

  Future<void> createBindingRequest({
    required String elderEmail,
    required String relationship,
  }) async {
    try {
      await _apiClient.post(
        '/bindings/request',
        data: {
          'elder_email': elderEmail,
          'relationship': relationship,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BindingRequest>> getPendingRequests() async {
    try {
      print('DEBUG: Requesting /bindings/pending/me');
      final response = await _apiClient.get('/bindings/pending/me');
      print('DEBUG: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('DEBUG: Received data: $data');
        return data
            .map((json) => BindingRequestDto.fromJson(json).toEntity())
            .toList();
      }
      return [];
    } catch (e) {
      print('DEBUG: getPendingRequests error: $e');
      rethrow;
    }
  }

  Future<void> respondToRequest(int bindingId, BindingStatus status) async {
    try {
      await _apiClient.put(
        '/bindings/$bindingId/respond',
        data: {'status': status.name},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    try {
      final response = await _apiClient.get('/bindings/family/members');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
