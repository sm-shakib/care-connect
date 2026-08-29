import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'caregiver.dart';

enum BookingStatus { pending, accepted, rejected, cancelled }

enum PaymentStatus { pending, paid }

class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.elderId,
    required this.caregiverId,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.paymentStatus,
    required this.requestedAt,
    this.reason = '',
    this.elderName = '',
    this.elderGender = '',
    this.elderAddress = '',
    this.requesterName = '',
    this.caregiverName = '',
    this.caregiverProfession = '',
    this.caregiverPhone = '',
    this.caregiverEntity,
  });

  final int id;
  final int elderId;
  final int caregiverId;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> daysOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final DateTime requestedAt;
  final String reason;
  
  /// Extra fields for UI display convenience
  final String elderName;
  final String elderGender;
  final String elderAddress;
  final String requesterName;
  final String caregiverName;
  final String caregiverProfession;
  final String caregiverPhone;
  final Caregiver? caregiverEntity;

  String get displayRequesterName =>
      requesterName.isNotEmpty ? requesterName : elderName;

  String get periodLabel =>
      '${DateFormat('MMM d, yyyy').format(startDate)} — ${DateFormat('MMM d, yyyy').format(endDate)}';

  String get workingDaysLabel => daysOfWeek.join(', ');

  String get timingLabel {
    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }
    return '${formatTimeOfDay(startTime)} — ${formatTimeOfDay(endTime)}';
  }

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    // Parse TimeOfDay from HH:mm:ss
    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    final elder = json['elder'] as Map<String, dynamic>?;
    final caregiver = json['caregiver'] as Map<String, dynamic>?;

    return BookingRequest(
      id: json['id'] as int,
      elderId: json['elder_id'] as int,
      caregiverId: json['caregiver_id'] as int,
      startDate: DateTime.parse(json['service_start_date'] as String),
      endDate: DateTime.parse(json['service_end_date'] as String),
      daysOfWeek: (json['days_of_week'] as String).split(','),
      startTime: parseTime(json['daily_timing_start'] as String),
      endTime: parseTime(json['daily_timing_end'] as String),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      requestedAt: DateTime.parse(json['requested_at'] as String).toLocal(),
      reason: json['booking_reason'] as String? ?? '',
      elderName: elder != null ? (elder['name'] as String? ?? '') : '',
      elderGender: elder != null ? (elder['gender'] as String? ?? '') : '',
      elderAddress: elder != null ? (elder['address'] as String? ?? '') : '',
      requesterName: '', // Could be fetched if needed
      caregiverName: caregiver != null ? (caregiver['name'] as String? ?? '') : '',
      caregiverProfession: caregiver != null ? (caregiver['profession'] as String? ?? 'Caregiver') : '',
      caregiverPhone: caregiver != null ? (caregiver['phone'] as String? ?? '') : '',
      caregiverEntity: caregiver != null ? Caregiver.fromJson(caregiver) : null,
    );
  }

  Map<String, dynamic> toJson() {
    String formatTime(TimeOfDay time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    }

    return {
      'elder_id': elderId,
      'caregiver_id': caregiverId,
      'service_start_date': startDate.toIso8601String().split('T')[0],
      'service_end_date': endDate.toIso8601String().split('T')[0],
      'days_of_week': daysOfWeek.join(','),
      'daily_timing_start': formatTime(startTime),
      'daily_timing_end': formatTime(endTime),
      'booking_reason': reason,
    };
  }

  BookingRequest copyWith({
    int? id,
    int? elderId,
    int? caregiverId,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? daysOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? requestedAt,
    String? reason,
    String? elderName,
    String? elderGender,
    String? elderAddress,
    String? requesterName,
    String? caregiverName,
    String? caregiverProfession,
    String? caregiverPhone,
    Caregiver? caregiverEntity,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      elderId: elderId ?? this.elderId,
      caregiverId: caregiverId ?? this.caregiverId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      requestedAt: requestedAt ?? this.requestedAt,
      reason: reason ?? this.reason,
      elderName: elderName ?? this.elderName,
      elderGender: elderGender ?? this.elderGender,
      elderAddress: elderAddress ?? this.elderAddress,
      requesterName: requesterName ?? this.requesterName,
      caregiverName: caregiverName ?? this.caregiverName,
      caregiverProfession: caregiverProfession ?? this.caregiverProfession,
      caregiverPhone: caregiverPhone ?? this.caregiverPhone,
      caregiverEntity: caregiverEntity ?? this.caregiverEntity,
    );
  }
}
