import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/dashboard_cubit.dart';
import 'dashboard_view.dart';

/// Route-level entry point for the admin dashboard — the root/home
/// screen of the admin flow. Provides [DashboardCubit] and kicks off
/// the initial load.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const DashboardPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit()..loadDashboard(),
      child: const DashboardView(),
    );
  }
}