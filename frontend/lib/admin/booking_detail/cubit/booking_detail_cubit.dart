import 'package:flutter_bloc/flutter_bloc.dart';

import 'booking_detail_model.dart';
import 'booking_detail_state.dart';

/// Loads a single booking's detail record.
///
/// NOTE: [loadBooking] looks [bookingId] up in a mock map below,
/// matching the same 3 bookings from `booking_management`'s mock data
/// (BK-3081/3082/3083) so the two screens stay consistent. Wire up to
/// your FastAPI `GET /admin/bookings/{id}` endpoint when ready.
class BookingDetailCubit extends Cubit<BookingDetailState> {
  BookingDetailCubit({required this.bookingId})
      : super(const BookingDetailState());

  final String bookingId;

  Future<void> loadBooking() async {
    emit(state.copyWith(loadStatus: BookingDetailLoadStatus.loading));
    try {
      // TODO(careconnect): replace with repository call to FastAPI
      // backend, fetching by `bookingId`.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final booking = _mockBookings[bookingId] ?? _mockBookings.values.first;
      emit(
        state.copyWith(
          loadStatus: BookingDetailLoadStatus.success,
          booking: booking,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: BookingDetailLoadStatus.failure,
          errorMessage: 'Unable to load this booking. Please try again.',
        ),
      );
    }
  }

  static const Map<String, BookingDetail> _mockBookings = {
    // Matches booking_management's BK-3082 (Ongoing) — the primary
    // example, since its status matches what the original HTML shows.
    'BK-3082': BookingDetail(
      id: 'BK-3082',
      category: 'Elderly Companion Care',
      status: BookingDetailStatus.ongoing,
      totalAmount: 1800,
      careRecipient: BookingParticipant(
        id: 'user-elderly-1',
        role: 'Care Recipient',
        name: 'Abdul Jabbar',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
        phoneNumber: '+880 1712-001122',
      ),
      caregiver: BookingParticipant(
        id: 'user-caregiver-1',
        role: 'Primary Caregiver',
        name: 'Salma Aktar',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
        phoneNumber: '+880 1812-001122',
      ),
      startDateLabel: 'Nov 02, 2023',
      endDateLabel: 'Nov 02, 2023',
      dailyTimingLabel: '08:00 AM - 02:00 PM (6 hrs)',
      address: 'House 5, Road 3, Mirpur, Dhaka',
      paymentBadges: [
        PaymentBadgeType.ongoing,
        PaymentBadgeType.partiallyPaid,
        PaymentBadgeType.checkedIn,
      ],
      careLogs: [
        CareLogEntry(
          label: 'Checked In',
          timeLabel: '08:02 AM, Nov 02',
          iconName: 'login',
        ),
      ],
    ),
    // Matches booking_management's BK-3081 (Upcoming) — nothing has
    // happened yet, so no care logs.
    'BK-3081': BookingDetail(
      id: 'BK-3081',
      category: 'Post-Op Recovery',
      status: BookingDetailStatus.upcoming,
      totalAmount: 2400,
      careRecipient: BookingParticipant(
        id: 'user-elderly-2',
        role: 'Care Recipient',
        name: 'Rahima Khatun',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
        phoneNumber: '+880 1912-001122',
      ),
      caregiver: BookingParticipant(
        id: 'user-caregiver-2',
        role: 'Primary Caregiver',
        name: 'Shakib Khan',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
        phoneNumber: '+880 1512-345678',
      ),
      startDateLabel: 'Oct 25, 2023',
      endDateLabel: 'Oct 27, 2023',
      dailyTimingLabel: '09:00 AM - 05:00 PM (8 hrs)',
      address: 'House 12, Road 5, Dhanmondi, Dhaka',
      paymentBadges: [
        PaymentBadgeType.confirmed,
        PaymentBadgeType.paid,
        PaymentBadgeType.notStarted,
      ],
      careLogs: [],
    ),
    // Matches booking_management's BK-3083 (Upcoming, unpaid) —
    // nothing has happened yet either.
    'BK-3083': BookingDetail(
      id: 'BK-3083',
      category: 'General Care',
      status: BookingDetailStatus.upcoming,
      totalAmount: 3200,
      careRecipient: BookingParticipant(
        id: 'user-elderly-3',
        role: 'Care Recipient',
        name: 'Rahela Begum',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
        phoneNumber: '+880 1612-001122',
      ),
      caregiver: BookingParticipant(
        id: 'user-caregiver-3',
        role: 'Primary Caregiver',
        name: 'Delwar Hossain',
        avatarUrl:
        'https://www.gstatic.com/labs-code/stitch/stitch-placeholder-300x300.svg',
        phoneNumber: '+880 1312-001122',
      ),
      startDateLabel: 'Nov 05, 2023',
      endDateLabel: 'Nov 10, 2023',
      dailyTimingLabel: '10:00 AM - 06:00 PM (8 hrs)',
      address: 'House 7, Sector 11, Uttara, Dhaka',
      paymentBadges: [PaymentBadgeType.pending, PaymentBadgeType.unpaid],
      careLogs: [],
    ),
  };
}