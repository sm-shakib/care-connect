import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/booking_request.dart';
import '../data/caregiver_request_dummy_data.dart';
import 'caregiver_request_state.dart';

class CaregiverRequestCubit extends Cubit<CaregiverRequestState> {
  CaregiverRequestCubit() : super(const CaregiverRequestState()) {
    _loadRequests();
  }

  void _loadRequests() {
    emit(state.copyWith(requests: CaregiverRequestDummyData.requests));
  }

  void acceptRequest(String id) {
    final updatedRequests = state.requests.map((r) {
      if (r.id == id) {
        return r.copyWith(status: BookingRequestStatus.accepted);
      }
      return r;
    }).toList();
    emit(state.copyWith(requests: updatedRequests));
  }

  void rejectRequest(String id) {
    final updatedRequests = state.requests.map((r) {
      if (r.id == id) {
        return r.copyWith(status: BookingRequestStatus.rejected);
      }
      return r;
    }).toList();
    emit(state.copyWith(requests: updatedRequests));
  }
}
