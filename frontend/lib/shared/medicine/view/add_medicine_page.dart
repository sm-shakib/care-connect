import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text(existing == null ? 'Add Medicine' : 'Edit Medicine'),
        centerTitle: true,
      ),
      body: AddMedicineView(
        existing: existing,
        onSave: (medicine) => Navigator.pop(context, medicine),
      ),
    );
  }
}
