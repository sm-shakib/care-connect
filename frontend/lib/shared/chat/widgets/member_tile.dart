import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

import '../models/chat_participant.dart';

/// A single contact/member row, shared by the "new chat/group" contact
/// picker and the group-info member list.
class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.participant,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  final ChatParticipant participant;
  final String? subtitle;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: participant.avatarColor,
        child: Text(
          participant.initials,
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkTeal),
        ),
      ),
      title: Text(participant.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ??
          (onTap == null
              ? null
              : Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? AppColors.darkTeal : colorScheme.outlineVariant,
                )),
    );
  }
}
