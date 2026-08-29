import 'package:equatable/equatable.dart';
import '../../models/booking_request.dart';

class CaregiverRequestState extends Equatable {
  const CaregiverRequestState({
    this.requests = const [],
    this.isLoading = false,
  });

  final List<BookingRequest> requests;
  final bool isLoading;

  List<BookingRequest> get pendingRequests =>
      requests.where((r) => r.status == BookingStatus.pending).toList();

  List<BookingRequest> get pastRequests =>
      requests.where((r) => r.status != BookingStatus.pending).toList();

  CaregiverRequestState copyWith({
    List<BookingRequest>? requests,
    bool? isLoading,
  }) {
    return CaregiverRequestState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [requests, isLoading];
}
