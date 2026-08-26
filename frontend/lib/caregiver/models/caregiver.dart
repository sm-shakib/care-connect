import 'package:flutter/material.dart';
import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/l10n/l10n.dart';

class Caregiver {
  Caregiver({
    required this.id,
    required this.name,
    required this.profession,
    required this.imageUrl,
    required this.rating,
    required this.experience,
    required this.distance,
    required this.hourlyRate,
    required this.isVerified,
    required this.specialties,
    required this.about,
    this.nameBn,
    this.professionBn,
    this.specializations = '',
    this.specializationsBn,
    this.aboutBn,
    this.gender = 'Female', // Default to Female as most caregivers are
    this.availabilityType = 'Full-time',
    this.availabilityTypeBn,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.addressBn,
    this.dateOfBirth,
    this.documents = const {},
    // this.latitude = 23.8103, // Default to Dhaka
    // this.longitude = 90.4125,
  });

  final String id;
  final String name;
  final String? nameBn;
  final String profession;
  final String? professionBn;
  final String imageUrl;
  final double rating;
  final int experience;
  final double distance;
  final int hourlyRate; // Rate in BDT per hour
  final bool isVerified;
  final List<String> specialties;
  final String specializations;
  final String? specializationsBn;
  final String about;
  final String? aboutBn;
  final String gender; // Added for gender-specific icons

  /// Matches the AvailabilityType options collected at caregiver signup
  /// (e.g. 'Full-time', 'Part-time', 'On-call', 'Weekends Only').
  final String availabilityType;
  final String? availabilityTypeBn;
  final String phone;
  final String email;
  final String address;
  final String? addressBn;
  final DateTime? dateOfBirth;
  final Map<CaregiverDocumentType, String> documents;

  // final double latitude;
  // final double longitude;

  Caregiver copyWith({
    String? id,
    String? name,
    String? nameBn,
    String? profession,
    String? professionBn,
    String? imageUrl,
    double? rating,
    int? experience,
    double? distance,
    int? hourlyRate,
    bool? isVerified,
    List<String>? specialties,
    String? specializations,
    String? specializationsBn,
    String? about,
    String? aboutBn,
    String? gender,
    String? availabilityType,
    String? availabilityTypeBn,
    String? phone,
    String? email,
    String? address,
    String? addressBn,
    DateTime? dateOfBirth,
    Map<CaregiverDocumentType, String>? documents,
    // double? latitude,
    // double? longitude,
  }) {
    return Caregiver(
      id: id ?? this.id,
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      profession: profession ?? this.profession,
      professionBn: professionBn ?? this.professionBn,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      experience: experience ?? this.experience,
      distance: distance ?? this.distance,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isVerified: isVerified ?? this.isVerified,
      specialties: specialties ?? this.specialties,
      specializations: specializations ?? this.specializations,
      specializationsBn: specializationsBn ?? this.specializationsBn,
      about: about ?? this.about,
      aboutBn: aboutBn ?? this.aboutBn,
      gender: gender ?? this.gender,
      availabilityType: availabilityType ?? this.availabilityType,
      availabilityTypeBn: availabilityTypeBn ?? this.availabilityTypeBn,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      addressBn: addressBn ?? this.addressBn,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      documents: documents ?? this.documents,
      // latitude: latitude ?? this.latitude,
      // longitude: longitude ?? this.longitude,
    );
  }


  /// Returns the localized name based on the current app locale.
  String getName(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        nameBn != null &&
        nameBn!.isNotEmpty) {
      return nameBn!;
    }
    return name;
  }

  /// Returns the localized profession based on the current app locale.
  String getProfession(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        professionBn != null &&
        professionBn!.isNotEmpty) {
      return professionBn!;
    }
    return profession;
  }

  /// Returns the localized specializations based on the current app locale.
  String getSpecializations(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        specializationsBn != null &&
        specializationsBn!.isNotEmpty) {
      return specializationsBn!;
    }
    return specializations;
  }

  /// Returns the localized about based on the current app locale.
  String getAbout(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        aboutBn != null &&
        aboutBn!.isNotEmpty) {
      return aboutBn!;
    }
    return about;
  }

  /// Returns the localized availability type based on the current app locale.
  String getAvailabilityType(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        availabilityTypeBn != null &&
        availabilityTypeBn!.isNotEmpty) {
      return availabilityTypeBn!;
    }
    return availabilityType;
  }

  /// Returns the localized address based on the current app locale.
  String getAddress(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        addressBn != null &&
        addressBn!.isNotEmpty) {
      return addressBn!;
    }
    return address;
  }

  /// Returns the localized gender label.
  String getGenderLabel(BuildContext context) {
    if (gender.toLowerCase() == 'male') {
      return context.l10n.genderMale;
    }
    return context.l10n.genderFemale;
  }

  /// Returns the localized specialty label.
  String getSpecialtyLabel(BuildContext context, String specialty) {
    switch (specialty) {
      case 'Physiotherapy':
        return context.l10n.filterPhysiotherapy;
      case 'Senior Care':
        return context.l10n.filterSeniorCare;
      case 'Home Nursing':
        return context.l10n.filterHomeNursing;
      default:
        return specialty;
    }
  }
}
