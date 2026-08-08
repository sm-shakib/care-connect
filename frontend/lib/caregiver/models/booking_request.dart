import 'package:equatable/equatable.dart';

enum BookingRequestStatus { pending, accepted, rejected }

class BookingRequest extends Equatable {
  const BookingRequest({
    required this.id,
    required this.elderName,
    required this.elderImageUrl,
    required this.requesterName,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.workingDays,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.requestedAt,
    this.bookingReason = '',
    this.elderGender = 'Male',
  });

  final String id;
  final String elderName;
  final String elderImageUrl;
  final String elderGender;
  final String requesterName;
  final String location;
  final String startDate;
  final String endDate;
  final List<String> workingDays;
  final String startTime;
  final String endTime;
  final BookingRequestStatus status;
  final DateTime requestedAt;
  final String bookingReason;

  String get periodLabel => '${startDate ?? ''} - ${endDate ?? ''}';
  String get workingDaysLabel => (workingDays ?? []).join(', ');
  String get timingLabel => '${startTime ?? ''} - ${endTime ?? ''}';

  BookingRequest copyWith({
    BookingRequestStatus? status,
    String? bookingReason,
    String? elderGender,
  }) {
    return BookingRequest(
      id: id,
      elderName: elderName,
      elderImageUrl: elderImageUrl,
      elderGender: elderGender ?? this.elderGender,
      requesterName: requesterName,
      location: location,
      startDate: startDate,
      endDate: endDate,
      workingDays: workingDays,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      requestedAt: requestedAt,
      bookingReason: bookingReason ?? this.bookingReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        elderName,
        elderImageUrl,
        elderGender,
        requesterName,
        location,
        startDate,
        endDate,
        workingDays,
        startTime,
        endTime,
        status,
        requestedAt,
        bookingReason,
      ];
}
