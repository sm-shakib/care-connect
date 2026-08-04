import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/family_member_detail_cubit.dart';
import 'family_member_detail_view.dart';

/// Route-level entry point for the Family Member Profile detail
/// feature. Provides [FamilyMemberDetailCubit] scoped to [userId] and
/// kicks off the initial load.
class FamilyMemberDetailPage extends StatelessWidget {
  const FamilyMemberDetailPage({required this.userId, super.key});

  final String userId;

  static Route<void> route({required String userId}) {
    return MaterialPageRoute<void>(
      builder: (_) => FamilyMemberDetailPage(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilyMemberDetailCubit(userId: userId)..loadProfile(),
      child: const FamilyMemberDetailView(),
    );
  }
}