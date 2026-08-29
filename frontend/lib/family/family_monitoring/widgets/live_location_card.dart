import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveLocationCard extends StatelessWidget {
  const LiveLocationCard({
    required this.locationImage,
    required this.updatedTime,
    this.latitude,
    this.longitude,
    super.key,
  });

  final String locationImage;
  final String updatedTime;
  final String? latitude;
  final String? longitude;

  Future<void> _openInMaps() async {
    if (latitude == null || longitude == null) return;
    
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = latitude != null && longitude != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Live Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceLight,
                        ),
                      ),
                    ),
                    Text(
                      updatedTime,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ],
                ),
                if (hasCoords) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Coords: ${latitude!.substring(0, 8)}, ${longitude!.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariantLight,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _openInMaps,
                        icon: const Icon(Icons.map, size: 16, color: AppColors.darkTeal),
                        label: const Text(
                          'Open in Google Maps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              if (hasCoords)
                Image.network(
                  'https://static-maps.yandex.ru/1.x/?ll=$longitude,$latitude&z=15&l=map&size=650,300',
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    locationImage,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Image.asset(
                  locationImage,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              if (hasCoords)
                const Icon(
                  Icons.person_pin_circle,
                  color: Colors.red,
                  size: 48,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
