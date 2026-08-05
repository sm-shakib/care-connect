import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/booking_detail_cubit.dart';
import 'booking_detail_view.dart';

/// Route-level entry point for the Booking Details feature. Provides
/// [BookingDetailCubit] scoped to [bookingId] and kicks off the
/// initial load.
class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({required this.bookingId, super.key});

  final String bookingId;

  static Route<void> route({required String bookingId}) {
    return MaterialPageRoute<void>(
      builder: (_) => BookingDetailPage(bookingId: bookingId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingDetailCubit(bookingId: bookingId)..loadBooking(),
      child: const BookingDetailView(),
    );
  }
}