import 'package:flutter/material.dart';

class LiveLocationCard extends StatelessWidget {
  const LiveLocationCard({
    super.key,
    required this.locationImage,
    required this.updatedTime,
  });

  final String locationImage;
  final String updatedTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                const Icon(
                  Icons.location_on,
                  color: Colors.teal,
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    "Live Location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  updatedTime,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

              ],
            ),
          ),

          Image.asset(
            locationImage,
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

        ],
      ),
    );
  }
}