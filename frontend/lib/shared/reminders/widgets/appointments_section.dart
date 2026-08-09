import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

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
        Row(
          children: [
            const Icon(Icons.calendar_month, color: AppColors.primaryLight, size: 26),
            const SizedBox(width: 10),
            Text(
              context.l10n.upcomingAppointmentsTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (appointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.outlineLight),
                const SizedBox(width: 12),
                Text(context.l10n.noUpcomingAppointments),
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

  Future<void> _openMaps(String location) async {
    final query = Uri.encodeComponent(location);
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query');
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.6,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  context.l10n.appointmentDateAtTime(
                    appointment.date,
                    appointment.time,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
                          fontSize: 18,
                          color: AppColors.deepTrustBlue,
                        ),
                      ),
                      Text(
                        appointment.specialty,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.outlineLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryLight),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appointment.location,
                              style: const TextStyle(
                                fontSize: 14,
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
                const SizedBox(width: 8),
                Material(
                  color: AppColors.paleMint,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => _openMaps(appointment.location),
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.directions,
                        color: AppColors.darkTeal,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
