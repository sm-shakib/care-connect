import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_dashboard_cubit.dart';
import 'caregiver_dashboard_view.dart';

class CaregiverDashboardPage extends StatelessWidget {
  const CaregiverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverDashboardCubit(),
      child: const CaregiverDashboardView(),
    );
  }
}