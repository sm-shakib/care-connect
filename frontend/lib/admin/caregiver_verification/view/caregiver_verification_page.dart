import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_verification_cubit.dart';
import 'caregiver_verification_view.dart';

/// Route-level entry point for the admin Caregiver Verification feature.
/// Provides [CaregiverVerificationCubit] and kicks off the initial load.
class CaregiverVerificationPage extends StatelessWidget {
  const CaregiverVerificationPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CaregiverVerificationPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverVerificationCubit()..loadCaregivers(),
      child: const CaregiverVerificationView(),
    );
  }
}