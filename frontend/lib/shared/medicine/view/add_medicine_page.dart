import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';

import '../models/medicine.dart';
import 'add_medicine_view.dart';

/// Standalone page for adding a new medicine, or editing [existing] one.
/// Pops with the saved [Medicine] on success.
class AddMedicinePage extends StatelessWidget {
  const AddMedicinePage({this.existing, super.key});

  final Medicine? existing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFEFC),
        title: Text(
          existing == null
              ? context.l10n.addMedicineLabel
              : context.l10n.editMedicineLabel,
        ),
        centerTitle: true,
      ),
      body: AddMedicineView(
        existing: existing,
        onSave: (medicine) => Navigator.pop(context, medicine),
      ),
    );
  }
}
