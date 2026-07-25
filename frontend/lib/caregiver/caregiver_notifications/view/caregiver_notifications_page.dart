import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/caregiver_notifications_cubit.dart';
import 'caregiver_notifications_view.dart';

class CaregiverNotificationsPage extends StatelessWidget {
  const CaregiverNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaregiverNotificationsCubit(),
      child: const CaregiverNotificationsView(),
    );
  }
}