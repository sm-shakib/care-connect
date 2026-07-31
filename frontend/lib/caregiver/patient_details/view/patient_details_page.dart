import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/patient_details_cubit.dart';
import 'patient_details_view.dart';

class PatientDetailsPage extends StatelessWidget {
  const PatientDetailsPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientDetailsCubit(
        patientId: patientId,
        patientName: patientName,
      ),
      child: const PatientDetailsView(),
    );
  }
}