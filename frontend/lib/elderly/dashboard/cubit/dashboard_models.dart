import 'package:equatable/equatable.dart';

/// A single medication reminder shown on the elderly dashboard.
class Medication extends Equatable {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isTaken = false,
  });

  final String id;
  final String name;
  final String dosage;

  /// Pre-formatted time label, e.g. "8:00 AM".
  final String time;
  final bool isTaken;

  Medication copyWith({bool? isTaken}) {
    return Medication(
      id: id,
      name: name,
      dosage: dosage,
      time: time,
      isTaken: isTaken ?? this.isTaken,
    );
  }

  @override
  List<Object?> get props => [id, name, dosage, time, isTaken];
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
  });

  final String id;
  final String name;
  final String profession;

  /// Pre-formatted label, e.g. "Today, 3:00 PM".
  final String nextVisitLabel;
  final String phone;

  @override
  List<Object?> get props => [id, name, profession, nextVisitLabel, phone];
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
