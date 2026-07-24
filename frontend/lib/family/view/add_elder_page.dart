import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/auth_dropdown_field.dart';
import 'package:frontend/core/widgets/auth_text_field.dart';
import 'package:frontend/theme/app_colors.dart';

class AddElderPage extends StatefulWidget {
  const AddElderPage({super.key});

  @override
  State<AddElderPage> createState() => _AddElderPageState();
}

class _AddElderPageState extends State<AddElderPage> {
  String? _relationship;
  final _emailController = TextEditingController();

  final List<String> _relationships = [
    'Father',
    'Mother',
    'Grandfather',
    'Grandmother',
    'Spouse',
    'Other'
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Add Loved One',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.person_add_outlined,
                size: 80,
                color: AppColors.darkTeal,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Link an Existing Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.deepTrustBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the email address your loved one used to register their CareConnect account.',
              style: TextStyle(
                color: AppColors.onSurfaceVariantLight,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),
            AuthTextField(
              label: 'Elder\'s Email',
              hintText: 'e.g. abdul.karim@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 24),
            AuthDropdownField<String>(
              label: 'Your Relationship',
              value: _relationship,
              items: _relationships,
              itemLabel: (r) => r,
              hintText: 'Select your relationship',
              onChanged: (val) => setState(() => _relationship = val),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate sending request
                  if (_emailController.text.isNotEmpty && _relationship != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Request sent to ${_emailController.text}. They will be added once they accept.',
                        ),
                        backgroundColor: AppColors.darkTeal,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Send Binding Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
