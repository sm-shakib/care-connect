import 'package:flutter/material.dart';

class BloodPressureCard extends StatelessWidget {
  const BloodPressureCard({
    super.key,
    required this.systolic,
    required this.diastolic,
    required this.status,
  });

  final int systolic;
  final int diastolic;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: const [

                Text(
                  "Blood Pressure",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Icon(
                  Icons.monitor_heart,
                  color: Colors.teal,
                ),

              ],
            ),

            const SizedBox(height: 18),

            RichText(
              text: TextSpan(
                children: [

                  TextSpan(
                    text: "$systolic/$diastolic",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                    ),
                  ),

                  const TextSpan(
                    text: " mmHg",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [

                const Icon(
                  Icons.circle_outlined,
                  size: 15,
                  color: Colors.teal,
                ),

                const SizedBox(width: 4),

                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.teal,
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