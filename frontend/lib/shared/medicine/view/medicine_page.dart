import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/medicine_cubit.dart';
import 'medicine_view.dart';

/// Standalone entry point for the medicine list, with its own
/// [MedicineCubit], [Scaffold], and [AppBar]. Use this when pushing the
/// medicine feature as its own route; embed [MedicineView] directly
/// (under a [BlocProvider]) when it belongs inside an existing tab layout.
class MedicinePage extends StatelessWidget {
  const MedicinePage({this.isElderly = false, super.key});

  final bool isElderly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicineCubit()..loadMedicines(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Medications'), centerTitle: true),
        body: MedicineView(isElderly: isElderly),
      ),
    );
  }
}
