import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/patient_details_cubit.dart';
import 'edit_reminders_view.dart';

class EditRemindersPage extends StatelessWidget {
  const EditRemindersPage({super.key, required this.cubit});

  /// The same [PatientDetailsCubit] instance the details page uses, so
  /// any add/edit/delete here is reflected immediately when navigating
  /// back — no separate state to keep in sync.
  final PatientDetailsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: const EditRemindersView(),
    );
  }
}