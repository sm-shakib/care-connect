import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_detail_cubit.dart';
import 'caregiver_detail_view.dart';

/// Route-level entry point for the Caregiver Profile detail feature.
/// Provides [CaregiverDetailCubit] scoped to [userId] and kicks off
/// the initial load.
class CaregiverDetailPage extends StatelessWidget {
  const CaregiverDetailPage({required this.userId, super.key});

  final String userId;

  static Route<void> route({required String userId}) {
    return MaterialPageRoute<void>(
      builder: (_) => CaregiverDetailPage(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverDetailCubit(userId: userId)..loadProfile(),
      child: const CaregiverDetailView(),
    );
  }
}