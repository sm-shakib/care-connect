import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import 'notifications_view.dart';

class NotificationsPage extends StatefulWidget {
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
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when opening the page
    context.read<DashboardCubit>().markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return const NotificationsView();
  }
}
