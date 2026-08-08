import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/user_model.dart';

/// A single row in the user management list, matching the design: a
/// circular avatar, name + role badge, phone/joined-date rows, an
/// active/suspended status dot, and a trailing overflow menu.
class UserListCard extends StatelessWidget {
  const UserListCard({
    required this.user,
    this.onTap,
    this.onViewDetails,
    this.onToggleStatus,
    this.onRemove,
    super.key,
  });

  final UserAccount user;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onRemove;

  _RoleStyle get _roleStyle => _RoleStyle.forRole(user.role);

  @override
  Widget build(BuildContext context) {
    final isSuspended = user.status == UserStatus.suspended;

    return Material(
      color: AppColors.surfaceContainerLowestLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariantLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(
                    user.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceContainerHighLight,
                      child: Icon(Icons.person, color: AppColors.outlineLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RoleBadge(style: _roleStyle),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(icon: Icons.call, text: user.phone),
                    const SizedBox(height: 2),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      text: 'Joined ${_formatDate(user.joinedDate)}',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSuspended
                                ? AppColors.errorLight
                                : AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSuspended ? 'Suspended' : 'Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSuspended
                                ? AppColors.errorLight
                                : AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_UserCardAction>(
                icon: Icon(Icons.more_vert, color: AppColors.onSurfaceVariantLight),
                onSelected: (action) {
                  switch (action) {
                    case _UserCardAction.viewDetails:
                      onViewDetails?.call();
                      break;
                    case _UserCardAction.toggleStatus:
                      onToggleStatus?.call();
                      break;
                    case _UserCardAction.remove:
                      onRemove?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _UserCardAction.viewDetails,
                    child: Text('View Details'),
                  ),
                  PopupMenuItem(
                    value: _UserCardAction.toggleStatus,
                    child: Text(isSuspended ? 'Reactivate' : 'Suspend'),
                  ),
                  const PopupMenuItem(
                    value: _UserCardAction.remove,
                    child: Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

enum _UserCardAction { viewDetails, toggleStatus, remove }

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariantLight),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariantLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.style});

  final _RoleStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: style.textColor,
        ),
      ),
    );
  }
}

/// Bundles the role-dependent badge colors in one place.
class _RoleStyle {
  const _RoleStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  factory _RoleStyle.forRole(UserRole role) {
    switch (role) {
      case UserRole.elderly:
        return _RoleStyle(
          label: 'Elderly',
          backgroundColor: AppColors.surfaceContainerHighLight,
          textColor: AppColors.onSurfaceVariantLight,
        );
      case UserRole.caregiver:
        return _RoleStyle(
          label: 'Caregiver',
          backgroundColor: AppColors.surfaceContainerHighLight,
          textColor: AppColors.onSurfaceVariantLight,
        );
      case UserRole.family:
        return _RoleStyle(
          label: 'Family',
          backgroundColor: AppColors.surfaceContainerHighLight,
          textColor: AppColors.onSurfaceVariantLight,
        );
      case UserRole.admin:
        return _RoleStyle(
          label: 'Admin',
          backgroundColor: AppColors.surfaceContainerHighLight,
          textColor: AppColors.onSurfaceVariantLight,
        );
    }
  }
}