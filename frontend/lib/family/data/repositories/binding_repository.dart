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
      final response = await _apiClient.get<List<dynamic>>('/bindings/pending/me');

      if (response.statusCode == 200) {
        final data = response.data ?? const <dynamic>[];
        return data
            .map(
              (json) => BindingRequestDto.fromJson(
                Map<String, dynamic>.from(json as Map),
              ).toEntity(),
            )
            .toList();
      }
      return const <BindingRequest>[];
    } catch (e) {
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
      final response = await _apiClient.get<List<dynamic>>('/bindings/family/members');
      if (response.statusCode == 200) {
        final data = response.data ?? const <dynamic>[];
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return const <Map<String, dynamic>>[];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLinkedFamilyMembers() async {
    try {
      final response = await _apiClient.get<List<dynamic>>('/bindings/elder/members');
      if (response.statusCode == 200) {
        final data = response.data ?? const <dynamic>[];
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return const <Map<String, dynamic>>[];
    } catch (e) {
      rethrow;
    }
  }
}
