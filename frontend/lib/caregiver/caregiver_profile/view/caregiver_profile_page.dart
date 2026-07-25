import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_profile_cubit.dart';
import 'caregiver_profile_view.dart';

class CaregiverProfilePage extends StatelessWidget {
  const CaregiverProfilePage({super.key, this.onLogOut});

  final VoidCallback? onLogOut;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverProfileCubit(),
      child: CaregiverProfileView(onLogOut: onLogOut),
    );
  }
}