import 'dart:convert';

/// Everything the shared [SosAlertScreen] needs to render, carried as a
/// notification's payload so the screen can display correctly even from a
/// cold start — before any notification list has loaded from the backend.
/// Mirrors `MedicineAlarmArgs` on the elder side.
class SosAlertArgs {
  const SosAlertArgs({
    required this.elderName,
    this.body,
    this.latitude,
    this.longitude,
  });

  final String elderName;
  final String? body;
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  String encode() => jsonEncode({
        'elderName': elderName,
        'body': body,
        'latitude': latitude,
        'longitude': longitude,
      });

  factory SosAlertArgs.decode(String payload) {
    final json = jsonDecode(payload) as Map<String, dynamic>;
    return SosAlertArgs(
      elderName: json['elderName'] as String? ?? 'Someone you care for',
      body: json['body'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
