import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/cubit/family_dashboard_cubit.dart';
import '../cubit/caregiver_list_cubit.dart';
import 'caregiver_list_view.dart';

class CaregiverListPage extends StatelessWidget {
  const CaregiverListPage({this.excludedIds, super.key});

  final List<String>? excludedIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CaregiverListCubit();
        if (excludedIds != null) {
          cubit.setExcludedIds(excludedIds!);
        }
        return cubit;
      },
      child: const CaregiverListView(),
    );
  }
}
