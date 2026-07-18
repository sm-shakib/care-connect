import 'package:flutter/material.dart';

class MedicationPlaceholder extends StatelessWidget {
  const MedicationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: ListTile(
          leading: Icon(
            Icons.medication,
            color: Colors.orange,
          ),
          title: Text("Medication Reminder"),
          subtitle: Text("Will be integrated from Elder Module"),
        ),
      ),
    );
  }
}