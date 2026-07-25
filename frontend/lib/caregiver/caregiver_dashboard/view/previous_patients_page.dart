import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_dashboard_cubit.dart';
import 'previous_patients_view.dart';

class PreviousPatientsPage extends StatelessWidget {
  const PreviousPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverDashboardCubit(),
      child: const PreviousPatientsView(),
    );
  }
}