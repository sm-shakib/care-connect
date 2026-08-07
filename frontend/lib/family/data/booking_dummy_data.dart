import '../models/booking_schedule.dart';

class BookingDummyData {
  static const BookingSchedule defaultSchedule = BookingSchedule(
    startDate: 'Jul 25, 2026',
    endDate: 'Aug 25, 2026',
    workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    startTime: '09:00 AM',
    endTime: '05:00 PM',
  );

  /// Helper to simulate fetching a schedule for a specific assigned caregiver.
  static BookingSchedule getScheduleForCaregiver(String caregiverId) {
    // For now, return the same dummy data for everyone.
    return defaultSchedule;
  }
}
