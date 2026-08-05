import 'package:equatable/equatable.dart';

import 'booking_detail_model.dart';

enum BookingDetailLoadStatus { initial, loading, success, failure }

class BookingDetailState extends Equatable {
  const BookingDetailState({
    this.loadStatus = BookingDetailLoadStatus.initial,
    this.booking,
    this.errorMessage,
  });

  final BookingDetailLoadStatus loadStatus;
  final BookingDetail? booking;
  final String? errorMessage;

  bool get isLoading => loadStatus == BookingDetailLoadStatus.loading;

  BookingDetailState copyWith({
    BookingDetailLoadStatus? loadStatus,
    BookingDetail? booking,
    String? errorMessage,
  }) {
    return BookingDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      booking: booking ?? this.booking,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [loadStatus, booking, errorMessage];
}