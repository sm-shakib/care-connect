import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import '../cubit/caregiver_list_cubit.dart';
import 'caregiver_list_view.dart';

class CaregiverListPage extends StatelessWidget {
  const CaregiverListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to get a reference elder for initial distance calculation
    /*
    final familyCubit = context.read<FamilyDashboardCubit>();
    final refElder = familyCubit.state.elders.isNotEmpty
        ? familyCubit.state.elders.first
        : null;
    */

    return BlocProvider(
      create: (_) => CaregiverListCubit()
        ..loadCaregivers(
          /*
          userLat: refElder?.latitude,
          userLng: refElder?.longitude,
          */
        ),
      child: const CaregiverListView(),
    );
  }
}
