import 'package:frontend/core/network/api_client.dart';

import '../models/medicine.dart';
import 'medicine_dto.dart';

/// Talks to the `/medicines` backend endpoints on behalf of the signed-in
/// elder. Every call is scoped server-side to that elder's own medicines.
class MedicineRepository {
  MedicineRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Medicine>> getMedicines() async {
    try {
      final response = await _apiClient.get('/medicines/me');
      final data = response.data as List;
      return data
          .map((json) => MedicineDto.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Medicine> createMedicine(Medicine medicine) async {
    try {
      final response = await _apiClient.post(
        '/medicines/',
        data: MedicineDto.fromEntity(medicine).toJson(),
      );
      return MedicineDto.fromJson(response.data as Map<String, dynamic>).toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<Medicine> updateMedicine(Medicine medicine) async {
    try {
      final response = await _apiClient.put(
        '/medicines/${medicine.id}',
        data: MedicineDto.fromEntity(medicine).toJson(),
      );
      return MedicineDto.fromJson(response.data as Map<String, dynamic>).toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    try {
      await _apiClient.delete('/medicines/$medicineId');
    } catch (e) {
      rethrow;
    }
  }

  /// Marks the dose scheduled for [time] as taken today. [time] must be one
  /// of the medicine's own `scheduleTimes` entries.
  Future<Medicine> markTaken(String medicineId, String time) async {
    try {
      final response = await _apiClient.patch(
        '/medicines/$medicineId/take',
        data: {'time': time},
      );
      return MedicineDto.fromJson(response.data as Map<String, dynamic>).toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
