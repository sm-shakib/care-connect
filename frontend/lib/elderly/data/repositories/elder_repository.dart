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
      data['last_location_update'] = DateFormat('jm').format(DateTime.now());
    }

    if (data.isEmpty) return;
    await _apiClient.put('/elders/me', data: data);
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _apiClient.get('/elders/me');
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _apiClient.put('/elders/me', data: data);
  }

  Future<void> updateElderVitals({
    required String elderId,
    required int heartRate,
    required int systolic,
    required int diastolic,
  }) async {
    await _apiClient.patch(
      '/elders/$elderId/vitals',
      data: {
        'heart_rate': heartRate,
        'systolic_bp': systolic,
        'diastolic_bp': diastolic,
      },
    );
  }

  // --- Appointments ---
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final response = await _apiClient.get('/elders/appointments');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<void> addAppointment(Map<String, dynamic> data) async {
    await _apiClient.post('/elders/appointments', data: data);
  }

  // --- Other Reminders ---
  Future<List<Map<String, dynamic>>> getReminders() async {
    final response = await _apiClient.get('/elders/reminders');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<void> addReminder(Map<String, dynamic> data) async {
    await _apiClient.post('/elders/reminders', data: data);
  }
}
