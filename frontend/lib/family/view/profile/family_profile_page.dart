import 'package:flutter/material.dart';
import 'package:frontend/login/view/login_page.dart';
import 'package:frontend/theme/app_colors.dart';
import 'donation_history_page.dart';

class FamilyProfilePage extends StatelessWidget {
  const FamilyProfilePage({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warningRed),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.paleMint,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=family_admin'),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Family Member',
              style: TextStyle(color: AppColors.onSurfaceVariantLight),
            ),
            const SizedBox(height: 32),
            _buildProfileTile(Icons.email_outlined, 'Email', 'john.doe@example.com'),
            _buildProfileTile(Icons.phone_outlined, 'Phone', '+880 123456789'),
            _buildProfileTile(Icons.location_on_outlined, 'Address', 'House 12, Road 5, Dhaka'),
            
            const SizedBox(height: 32),
            
            /// Donation System - Prominent Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.paleMint,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.volunteer_activism, size: 40, color: AppColors.primaryLight),
                  const SizedBox(height: 12),
                  const Text(
                    'CareConnect Central Fund',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Support elders who cannot afford caregiving services. Your contribution makes a difference.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariantLight),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _showDonationDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Donate Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildActionTile(context, Icons.history, 'Donation History', () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const DonationHistoryPage()),
              );
            }),
            _buildActionTile(context, Icons.logout, 'Logout', () => _handleLogout(context), isDestructive: true),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariantLight),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryLight),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariantLight),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.primaryLight),
        title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : Colors.black, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showDonationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Donate to Central Fund', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your donation helps underprivileged elders receive care.'),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Amount (৳)',
                prefixText: '৳ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Your donation was successful.'),
                  backgroundColor: AppColors.darkTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkTeal, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Donation'),
          ),
        ],
      ),
    );
  }
}
