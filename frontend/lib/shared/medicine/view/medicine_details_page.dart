import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';

import '../models/medicine.dart';
import 'add_medicine_page.dart';
import 'medicine_details_view.dart';

/// Standalone page showing a single medicine's details. Pops with the
/// updated [Medicine] if the user edits it, so the caller can persist
/// the change via the cubit.
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
      body: MedicineDetailsView(
        medicine: medicine,
        onEdit: () async {
          final updated = await Navigator.push<Medicine>(
            context,
            MaterialPageRoute(
              builder: (_) => AddMedicinePage(existing: medicine),
            ),
          );
          if (updated != null && context.mounted) {
            Navigator.pop(context, updated);
          }
        },
      ),
    );
  }
}
