import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_pending_cubit.dart';
import 'caregiver_pending_view.dart';

class CaregiverPendingPage extends StatelessWidget {
  const CaregiverPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverPendingCubit(),
      child: const CaregiverPendingView(),
    );
  }
}