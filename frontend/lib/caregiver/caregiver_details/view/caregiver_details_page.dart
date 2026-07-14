import 'package:flutter/material.dart';

import '../../models/caregiver.dart';

class CaregiverDetailsPage extends StatelessWidget {
  final Caregiver caregiver;

  const CaregiverDetailsPage({
    super.key,
    required this.caregiver,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caregiver Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Profile
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal.shade100,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.teal,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                caregiver.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Center(
              child: Text(
                caregiver.profession,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text("Rating"),
                trailing: Text(caregiver.rating.toString()),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text("Distance"),
                trailing: Text("${caregiver.distance} km"),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: const Text("Hourly Rate"),
                trailing: Text("\$${caregiver.hourlyRate}/hr"),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Specialties",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: caregiver.specialties
                  .map(
                    (e) => Chip(
                  label: Text(e),
                ),
              )
                  .toList(),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Booking ${caregiver.name}...",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}