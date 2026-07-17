import 'package:flutter/material.dart';

class CaregiverStatusCard extends StatelessWidget {
  const CaregiverStatusCard({
    super.key,
    required this.caregiverName,
    required this.onTap,
  });

  final String caregiverName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [

              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal.shade100,
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Caregiver: $caregiverName",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Row(
                      children: [

                        CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.teal,
                        ),

                        SizedBox(width: 6),

                        Text(
                          "On Duty Now",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}