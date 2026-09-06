import 'package:flutter/material.dart';
import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyMemberDetailsPage extends StatelessWidget {
  const FamilyMemberDetailsPage({
    required this.member,
    super.key,
  });

  final Map<String, dynamic> member;

  @override
  Widget build(BuildContext context) {
    final name = member['name'] as String? ?? 'Family Member';
    final imageUrl = member['profile_image_url'] as String? ?? '';
    final phone = member['phone'] as String? ?? '';
    final email = member['email'] as String? ?? '';
    final address = member['address'] as String? ?? '';
    final gender = member['gender'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        title: const Text(
          'Family Member Profile',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.paleMint,
                    backgroundImage:
                        imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.person,
                            color: AppColors.darkTeal, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard([
              _buildInfoRow(Icons.phone_outlined, 'Phone Number', phone),
              _buildInfoRow(Icons.email_outlined, 'Email Address', email),
              _buildInfoRow(Icons.location_on_outlined, 'Address', address),
              _buildInfoRow(Icons.person_outline, 'Gender', gender),
            ]),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openDirectConversation(
                      context,
                      contactName: name,
                      role: ChatRole.family,
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.darkTeal,
                      side: const BorderSide(color: AppColors.darkTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (phone.isNotEmpty) {
                        final uri = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.darkTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paleMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.darkTeal, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceLight,
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
