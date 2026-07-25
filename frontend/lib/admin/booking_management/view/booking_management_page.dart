import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/booking_management_cubit.dart';
import 'booking_management_view.dart';

/// Standalone route entry point for Bookings (e.g. for isolated
/// testing). The main app flow renders [BookingManagementView] directly
/// as a tab body inside `AdminShellView` instead — see `admin_shell`.
class BookingManagementPage extends StatelessWidget {
  const BookingManagementPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const BookingManagementPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingManagementCubit()..loadBookings(),
      child: const BookingManagementView(),
    );
  }
}