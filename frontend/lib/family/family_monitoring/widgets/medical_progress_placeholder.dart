import 'package:flutter/material.dart';

class MedicalProgressPlaceholder extends StatelessWidget {
  const MedicalProgressPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: ListTile(
          leading: Icon(
            Icons.analytics,
            color: Colors.blue,
          ),
          title: Text("Medical Progress"),
          subtitle: Text("Will be integrated from Elder Module"),
        ),
      ),
    );
  }
}