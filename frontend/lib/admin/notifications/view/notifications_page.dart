import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import 'notifications_view.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static Route<void> route(DashboardCubit dashboardCubit) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: dashboardCubit,
        child: const NotificationsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const NotificationsView();
  }
}
