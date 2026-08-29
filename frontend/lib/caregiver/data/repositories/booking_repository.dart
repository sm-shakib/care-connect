import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/caregiver/models/booking_request.dart';

class BookingRepository {
  final ApiClient _apiClient = ApiClient();

  Future<BookingRequest> createBooking(BookingRequest booking) async {
    final response = await _apiClient.post(
      ApiConstants.bookings,
      data: booking.toJson(),
    );
    return BookingRequest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BookingRequest>> getCaregiverBookings(int caregiverId) async {
    final response = await _apiClient.get(
      ApiConstants.caregiverBookings(caregiverId),
    );
    final data = response.data as List<dynamic>;
    return data
        .map((json) => BookingRequest.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookingRequest>> getElderBookings(int elderId) async {
    final response = await _apiClient.get(
      '/bookings/elder/$elderId',
    );
    final data = response.data as List<dynamic>;
    return data
        .map((json) => BookingRequest.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<BookingRequest> updateBookingStatus(
    int bookingId,
    BookingStatus status,
  ) async {
    final response = await _apiClient.patch(
      ApiConstants.bookingDetail(bookingId),
      data: {'status': status.name},
    );
    return BookingRequest.fromJson(response.data as Map<String, dynamic>);
  }
}
