import 'package:flutter/material.dart';

class AppointmentsPlaceholder extends StatelessWidget {
  const AppointmentsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: ListTile(
          leading: Icon(
            Icons.calendar_month,
            color: Colors.green,
          ),
          title: Text("Appointments"),
          subtitle: Text("Will be integrated from Elder Module"),
        ),
      ),
    );
  }
}