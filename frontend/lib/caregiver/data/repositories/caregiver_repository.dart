import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/caregiver/models/caregiver.dart';

class CaregiverRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<Caregiver>> getCaregivers() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.caregivers,
    );
    final data = response.data!;
    return data
        .map((json) => Caregiver.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Caregiver> getCaregiverById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.caregiverDetailPublic(id),
    );
    return Caregiver.fromJson(response.data!);
  }
}
