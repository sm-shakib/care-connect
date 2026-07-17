import 'package:flutter/material.dart';

class HeartRateCard extends StatelessWidget {
  const HeartRateCard({
    super.key,
    required this.heartRate,
    required this.status,
  });

  final int heartRate;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [

                Text(
                  "Heart Rate",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),

              ],
            ),

            const SizedBox(height: 18),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$heartRate",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: " bpm",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "~ $status",
              style: const TextStyle(
                color: Colors.teal,
              ),
            ),

          ],
        ),
      ),
    );
  }
}