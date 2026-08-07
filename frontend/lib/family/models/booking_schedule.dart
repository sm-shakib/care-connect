import 'package:equatable/equatable.dart';

class BookingSchedule extends Equatable {
  const BookingSchedule({
    required this.startDate,
    required this.endDate,
    required this.workingDays,
    required this.startTime,
    required this.endTime,
  });

  final String startDate;
  final String endDate;
  final List<String> workingDays;
  final String startTime;
  final String endTime;

  String get periodLabel => '$startDate - $endDate';
  String get workingDaysLabel => workingDays.join(', ');
  String get timingLabel => '$startTime - $endTime';

  @override
  List<Object?> get props => [startDate, endDate, workingDays, startTime, endTime];
}
