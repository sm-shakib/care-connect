import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/elderly_detail_cubit.dart';
import 'elderly_detail_view.dart';

/// Route-level entry point for the Elderly Profile detail feature.
/// Provides [ElderlyDetailCubit] scoped to [userId] and kicks off the
/// initial load.
class ElderlyDetailPage extends StatelessWidget {
  const ElderlyDetailPage({required this.userId, super.key});

  final String userId;

  static Route<void> route({required String userId}) {
    return MaterialPageRoute<void>(
      builder: (_) => ElderlyDetailPage(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ElderlyDetailCubit(userId: userId)..loadProfile(),
      child: const ElderlyDetailView(),
    );
  }
}