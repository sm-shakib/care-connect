import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import '../../../caregiver/models/booking_request.dart';
import '../../../caregiver/models/caregiver.dart';
import '../../../../shared/medicine/models/medication.dart';

export '../../../../shared/medicine/models/medication.dart';

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
