import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/l10n/l10n.dart';

import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_state.dart';
import '../models/medicine.dart';
import 'add_medicine_page.dart';
import 'medicine_details_view.dart';

/// Standalone page showing a single medicine's details. Pops with the
/// updated [Medicine] if the user edits it, so the caller can persist
/// the change via the cubit. Reads the live [MedicineCubit] so a dose
/// marked taken from here (or anywhere else) shows up immediately —
/// the caller must forward that cubit across the route boundary (see
/// [MedicineCubit] usage in `medicine_view.dart`).
class MedicineDetailsPage extends StatelessWidget {
  const MedicineDetailsPage({required this.medicine, super.key});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFEFC),
        title: Text(context.l10n.medicineDetailsTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<MedicineCubit, MedicineState>(
        builder: (context, state) {
          final current = state.medicines.firstWhere(
            (m) => m.id == medicine.id,
            orElse: () => medicine,
          );

          return MedicineDetailsView(
            medicine: current,
            onMarkTaken: (time) =>
                context.read<MedicineCubit>().markTaken(current.id, time),
            onEdit: () async {
              final updated = await Navigator.push<Medicine>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddMedicinePage(existing: current),
                ),
              );
              if (updated != null && context.mounted) {
                Navigator.pop(context, updated);
              }
            },
          );
        },
      ),
    );
  }
}
