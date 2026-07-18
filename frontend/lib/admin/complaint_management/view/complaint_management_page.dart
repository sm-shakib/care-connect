import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/complaint_management_cubit.dart';
import 'complaint_management_view.dart';

/// Route-level entry point for the admin Complaints feature. Provides
/// [ComplaintManagementCubit] and kicks off the initial load.
class ComplaintManagementPage extends StatelessWidget {
  const ComplaintManagementPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ComplaintManagementPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplaintManagementCubit()..loadComplaints(),
      child: const ComplaintManagementView(),
    );
  }
}