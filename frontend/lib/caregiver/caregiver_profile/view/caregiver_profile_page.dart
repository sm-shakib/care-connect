import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_profile_cubit.dart';
import 'caregiver_profile_view.dart';

class CaregiverProfilePage extends StatelessWidget {
  const CaregiverProfilePage({super.key, this.onLogOut, this.showTopBar = true});

  final VoidCallback? onLogOut;

  /// Set to false when embedding this page as tab content inside a shell
  /// that already provides its own "Profile" app bar (e.g. the caregiver
  /// bottom-nav shell), to avoid showing two stacked title bars.
  final bool showTopBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverProfileCubit(),
      child: CaregiverProfileView(onLogOut: onLogOut, showTopBar: showTopBar),
    );
  }
}