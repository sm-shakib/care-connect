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
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ===========================
            /// Top Section
            /// ===========================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xffD6F5F2),

                  child: const Icon(
                    Icons.person,
                    color: Color(0xff00897B),
                    size: 38,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              caregiver.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),

                          const SizedBox(width: 2),

                          Text(
                            caregiver.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        caregiver.profession,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius:
                          BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.green,
                            ),

                            SizedBox(width: 4),

                            Text(
                              "NID Verified",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// ===========================
            /// Specialties
            /// ===========================
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: caregiver.specialties
                  .map(
                    (item) => Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),

            const SizedBox(height: 18),

            /// ===========================
            /// Distance & Price
            /// ===========================
            Row(
              children: [

                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.red,
                  size: 18,
                ),

                const SizedBox(width: 4),

                Text(
                  "${caregiver.distance} km away",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const Spacer(),

                Text(
                  "\$${caregiver.hourlyRate}/hr",
                  style: const TextStyle(
                    color: Color(0xff00897B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// ===========================
            /// Button
            /// ===========================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff00897B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}