import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

class ChatTopBar extends StatelessWidget {
  const ChatTopBar({
    super.key,
    required this.contactName,
    this.isGroup = false,
    this.onBack,
    this.onCall,
    this.onVideoCall,
  });

  final String contactName;
  final bool isGroup;
  final VoidCallback? onBack;
  final VoidCallback? onCall;
  final VoidCallback? onVideoCall;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.paleMint,
            child: Icon(
              // child: const Icon(Icons.person, size: 20, color: AppColors.darkTeal),
              isGroup ? Icons.groups_2_outlined : Icons.person,
              size: 20,
              color: AppColors.darkTeal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              contactName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, color: colorScheme.primary),
            onPressed: onCall,
          ),
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: colorScheme.primary),
            onPressed: onVideoCall,
          ),
        ],
      ),
    );
  }
}