import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/appointment.dart';

/// Read-only "Upcoming Appointments" list for an elder being monitored.
class AppointmentsSection extends StatelessWidget {
  const AppointmentsSection({required this.appointments, super.key});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Appointments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 12),
        if (appointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.outlineLight),
                SizedBox(width: 12),
                Text('No upcoming appointments.'),
              ],
            ),
          )
        else
          ...appointments.map((appointment) => _AppointmentTile(appointment: appointment)),
      ],
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${appointment.date} at ${appointment.time}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.deepTrustBlue,
                        ),
                      ),
                      Text(
                        appointment.specialty,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.outlineLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primaryLight),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appointment.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariantLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.paleMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions, color: AppColors.darkTeal, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
