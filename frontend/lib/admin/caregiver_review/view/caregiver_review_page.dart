import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_review_cubit.dart';
import 'caregiver_review_view.dart';

/// Route-level entry point for the admin Caregiver Application Review
/// feature. Provides [CaregiverReviewCubit] scoped to [applicationId]
/// and kicks off the initial load.
class CaregiverReviewPage extends StatelessWidget {
  const CaregiverReviewPage({required this.applicationId, super.key});

  final String applicationId;

  static Route<void> route({required String applicationId}) {
    return MaterialPageRoute<void>(
      builder: (_) => CaregiverReviewPage(applicationId: applicationId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverReviewCubit(applicationId: applicationId)
        ..loadApplication(),
      child: const CaregiverReviewView(),
    );
  }
}