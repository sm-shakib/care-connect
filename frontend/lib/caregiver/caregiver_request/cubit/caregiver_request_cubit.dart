import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/booking_request.dart';
import '../../data/repositories/booking_repository.dart';
import '../../../core/repositories/auth_repository.dart';
import 'caregiver_request_state.dart';

class CaregiverRequestCubit extends Cubit<CaregiverRequestState> {
  CaregiverRequestCubit() : super(const CaregiverRequestState()) {
    loadRequests();
  }

  final _bookingRepository = BookingRepository();
  final _authRepository = AuthRepository();

  Future<void> loadRequests() async {
    emit(state.copyWith(isLoading: true));
    try {
      final caregiverId = await _authRepository.getProfileId();
      if (caregiverId != null) {
        final requests = await _bookingRepository.getCaregiverBookings(caregiverId);
        emit(state.copyWith(requests: requests, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> acceptRequest(int id) async {
    try {
      await _bookingRepository.updateBookingStatus(id, BookingStatus.accepted);
      final updatedRequests = state.requests.map((r) {
        if (r.id == id) {
          return r.copyWith(status: BookingStatus.accepted);
        }
        return r;
      }).toList();
      emit(state.copyWith(requests: updatedRequests));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> rejectRequest(int id) async {
    try {
      await _bookingRepository.updateBookingStatus(id, BookingStatus.rejected);
      final updatedRequests = state.requests.map((r) {
        if (r.id == id) {
          return r.copyWith(status: BookingStatus.rejected);
        }
        return r;
      }).toList();
      emit(state.copyWith(requests: updatedRequests));
    } catch (e) {
      // Handle error
    }
  }
}
