import 'package:flutter/material.dart';

import '../models/elder.dart';

class ElderCard extends StatelessWidget {
  const ElderCard({
    super.key,
    required this.elder,
    required this.onTap,
  });

  final Elder elder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              /// Elder Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal.shade100,
                child: Icon(
                  elder.gender == 'Male'
                      ? Icons.man
                      : Icons.woman,
                  size: 34,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    /// Name
                    Text(
                      elder.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${elder.relationship} • ${elder.age} years",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [

                        Icon(
                          Icons.medical_services,
                          size: 18,
                          color: Colors.teal.shade700,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            elder.hasCaregiver
                                ? elder.caregiverName
                                : "No caregiver assigned",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: elder.hasCaregiver
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                      child: Text(
                        elder.healthStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: elder.hasCaregiver
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}