import 'package:flutter/material.dart';

import '../models/caregiver.dart';

class CaregiverCard extends StatelessWidget {
  final Caregiver caregiver;
  final VoidCallback onTap;

  const CaregiverCard({
    super.key,
    required this.caregiver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Profile Section
            Row(
              children: [

                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.teal.shade100,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        caregiver.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        caregiver.profession,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [

                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            caregiver.rating.toString(),
                          ),

                          const SizedBox(width: 15),

                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.red,
                          ),

                          Text(
                            "${caregiver.distance} km",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              children: caregiver.specialties
                  .map(
                    (specialty) => Chip(
                  label: Text(
                    specialty,
                  ),
                ),
              )
                  .toList(),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "\$${caregiver.hourlyRate}/hr",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),

                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "View Details",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}