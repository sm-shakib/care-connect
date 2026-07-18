import 'package:flutter/material.dart';

class MonitoringHeader extends StatelessWidget {
  const MonitoringHeader({
    super.key,
    required this.elderName,
  });

  final String elderName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.teal.shade100,
          child: const Icon(
            Icons.person,
            color: Colors.teal,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "CareConnect",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              Text(
                "Monitoring $elderName",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),

            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }
}