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

  /// Fires an SOS: the backend shares this location (falling back to the
  /// elder's last known one if [latitude]/[longitude] are omitted) with
  /// every accepted family member and caregiver — see
  /// `backend/app/api/elder.py::trigger_sos`.
  Future<Map<String, dynamic>> triggerSos({
    double? latitude,
    double? longitude,
  }) async {
    final data = <String, dynamic>{};
    if (latitude != null) data['latitude'] = latitude.toString();
    if (longitude != null) data['longitude'] = longitude.toString();

    final response = await _apiClient.post('/elders/sos', data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _apiClient.get('/elders/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getElderProfile(int elderId) async {
    final response = await _apiClient.get('/elders/$elderId');
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
  Future<List<Map<String, dynamic>>> getAppointments({int? elderId}) async {
    final path = elderId != null ? '/elders/$elderId/appointments' : '/elders/appointments';
    final response = await _apiClient.get(path);
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<void> addAppointment(Map<String, dynamic> data, {int? elderId}) async {
    final queryParams = elderId != null ? {'elder_id': elderId} : null;
    await _apiClient.post('/elders/appointments', data: data, queryParameters: queryParams);
  }

  Future<void> updateAppointment(int appointmentId, Map<String, dynamic> data) async {
    await _apiClient.put('/elders/appointments/$appointmentId', data: data);
  }

  Future<void> deleteAppointment(int appointmentId) async {
    await _apiClient.delete('/elders/appointments/$appointmentId');
  }

  // --- Other Reminders ---
  Future<List<Map<String, dynamic>>> getReminders({int? elderId}) async {
    final path = elderId != null ? '/elders/$elderId/reminders' : '/elders/reminders';
    final response = await _apiClient.get(path);
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<void> addReminder(Map<String, dynamic> data, {int? elderId}) async {
    final queryParams = elderId != null ? {'elder_id': elderId} : null;
    await _apiClient.post('/elders/reminders', data: data, queryParameters: queryParams);
  }

  Future<void> updateReminder(int reminderId, Map<String, dynamic> data) async {
    await _apiClient.put('/elders/reminders/$reminderId', data: data);
  }

  Future<void> deleteReminder(int reminderId) async {
    await _apiClient.delete('/elders/reminders/$reminderId');
  }
}
