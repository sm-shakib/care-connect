import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/family_member_profile_model.dart';

/// "Alert Preferences" card — a display-only list of which
/// notification categories this family member has enabled. Not
/// editable from this admin screen.
class AlertPreferencesCard extends StatelessWidget {
  const AlertPreferencesCard({required this.preferences, super.key});

  final List<AlertPreference> preferences;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: AppColors.surfaceContainerLight,
            child: Text(
              'Alert Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceLight,
              ),
            ),
          ),
          for (var i = 0; i < preferences.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: AppColors.outlineVariantLight),
            _PreferenceRow(preference: preferences[i]),
          ],
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.preference});

  final AlertPreference preference;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                preference.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              preference.isEnabled
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: preference.isEnabled
                  ? AppColors.primaryLight
                  : AppColors.outlineLight,
            ),
          ],
        ),
      ),
    );
  }
}