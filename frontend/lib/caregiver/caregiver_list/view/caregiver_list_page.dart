import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/caregiver_list_cubit.dart';
import 'caregiver_list_view.dart';

class CaregiverListPage extends StatelessWidget {
  const CaregiverListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverListCubit()..loadCaregivers(),
      child: const CaregiverListView(),
    );
  }
}
