import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import '../../../caregiver/models/booking_request.dart';
import '../../../caregiver/models/caregiver.dart';

/// A single medication reminder shown on the elderly dashboard.
class Medication extends Equatable {
  const Medication({
    required this.id,
    required this.name,
    this.nameBn,
    required this.dosage,
    required this.time,
    this.isTaken = false,
  });

  final String id;
  final String name;
  final String? nameBn;
  final String dosage;

  /// Pre-formatted time label, e.g. "8:00 AM".
  final String time;
  final bool isTaken;

  /// Returns the localized name based on the current app locale.
  String getName(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'bn' &&
        nameBn != null &&
        nameBn!.isNotEmpty) {
      return nameBn!;
    }
    return name;
  }

  Medication copyWith({bool? isTaken}) {
    return Medication(
      id: id,
      name: name,
      nameBn: nameBn,
      dosage: dosage,
      time: time,
      isTaken: isTaken ?? this.isTaken,
    );
  }

  @override
  List<Object?> get props => [id, name, nameBn, dosage, time, isTaken];
}

/// Summary of the elderly user's assigned caregiver, shown on the
/// dashboard with quick call/message actions.
class CaregiverSummary extends Equatable {
  const CaregiverSummary({
    required this.id,
    required this.name,
    required this.profession,
    required this.nextVisitLabel,
    required this.phone,
    this.entity,
    this.booking,
  });

  final String id;
  final String name;
  final String profession;

  /// Pre-formatted label, e.g. "Today, 3:00 PM".
  final String nextVisitLabel;
  final String phone;
  final Caregiver? entity;
  final BookingRequest? booking;

  @override
  List<Object?> get props =>
      [id, name, profession, nextVisitLabel, phone, entity, booking];
}

/// Preview of the most recent chat message shown on the dashboard.
class ChatPreview extends Equatable {
  const ChatPreview({
    required this.senderName,
    required this.lastMessage,
    required this.timeLabel,
    this.unreadCount = 0,
  });

  final String senderName;
  final String lastMessage;

  /// Pre-formatted label, e.g. "10 min ago".
  final String timeLabel;
  final int unreadCount;

  @override
  List<Object?> get props => [senderName, lastMessage, timeLabel, unreadCount];
}
