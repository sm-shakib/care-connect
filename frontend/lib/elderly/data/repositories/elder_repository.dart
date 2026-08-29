import 'package:frontend/core/network/api_client.dart';
import 'package:intl/intl.dart';

class ElderRepository {
  final ApiClient _apiClient;

  ElderRepository(this._apiClient);

  /// Update the elder's health vitals and location in the database.
  Future<void> updateVitalsAndLocation({
    int? heartRate,
    int? systolicBp,
    int? diastolicBp,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> data = {};
    
    if (heartRate != null) data['heart_rate'] = heartRate;
    if (systolicBp != null) data['systolic_bp'] = systolicBp;
    if (diastolicBp != null) data['diastolic_bp'] = diastolicBp;
    
    if (latitude != null) data['latitude'] = latitude.toString();
    if (longitude != null) data['longitude'] = longitude.toString();
    
    if (latitude != null || longitude != null) {
      data['last_location_update'] = DateFormat('jm').format(DateTime.now()); // e.g. "4:30 PM"
    }

    if (data.isEmpty) return;

    await _apiClient.put('/me', data: data);
  }
}
