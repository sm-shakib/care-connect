import 'package:frontend/core/enums/gender.dart';

// TODO: replace with a real repository call once the profile API exists.
class FamilyProfileDummyData {
  static const String name = 'Ayesha Akhter';
  static const String email = 'ayesha@gmail.com';
  static const String phone = '+880 173456789';
  static const String address = 'House 12, Road 5, Dhaka';
  static const Gender gender = Gender.female;
  static final DateTime dateOfBirth = DateTime(1985, 6, 15);
}
