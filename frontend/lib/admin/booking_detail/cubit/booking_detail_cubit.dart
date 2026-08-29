import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/repositories/admin_repository.dart';

import 'booking_detail_model.dart';
import 'booking_detail_state.dart';

/// Loads a single booking's detail record.
class BookingDetailCubit extends Cubit<BookingDetailState> {
  BookingDetailCubit({
    required this.bookingId,
    AdminRepository? adminRepository,
  })  : _adminRepository = adminRepository ?? AdminRepository(),
        super(const BookingDetailState());

  final String bookingId;
  final AdminRepository _adminRepository;

  Future<void> loadBooking() async {
    emit(state.copyWith(loadStatus: BookingDetailLoadStatus.loading));
    try {
      // The bookingId passed from the list includes the 'BK-' prefix.
      final id = int.parse(bookingId.replaceFirst('BK-', ''));
      final data = await _adminRepository.getAdminBookingDetail(id);

      final booking = BookingDetail.fromJson(data);

      emit(
        state.copyWith(
          loadStatus: BookingDetailLoadStatus.success,
          booking: booking,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          loadStatus: BookingDetailLoadStatus.failure,
          errorMessage: 'Unable to load this booking. Please try again.',
        ),
      );
    }
  }
}
