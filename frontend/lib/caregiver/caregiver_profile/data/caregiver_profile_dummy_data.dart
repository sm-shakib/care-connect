import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/core/enums/gender.dart';

// TODO: replace with a real repository call once the profile API exists.
class CaregiverProfileDummyData {
  static const String name = 'Nafis Ahmed';
  static const String email = 'nafis@gmail.com';
  static const String phone = '+8801717790950';
  static const String address = 'Dhaka';
  static const Gender gender = Gender.male;
  static final DateTime dateOfBirth = DateTime(2001, 4, 12);
  static const String specializations =
      'Elderly mobility support';
  static const AvailabilityType availabilityType = AvailabilityType.fullTime;
  static const String dailyRate = '1000';
  static const String experienceYears = '2';

  static const Map<CaregiverDocumentType, String> documents = {
    CaregiverDocumentType.nationalId: 'nid_scan.pdf',
    CaregiverDocumentType.certificate: 'caregiving_certificate.pdf',
    CaregiverDocumentType.policeClearance: 'police_clearance.pdf',
  };

  static const double totalEarningsThisMonth = 3240.00;
  static const double lastPayoutAmount = 850.00;
  static final DateTime lastPayoutDate = DateTime(2024, 6, 15);
  static const List<double> earningsSparkline = [40, 60, 35, 75, 50, 90, 85];
}