import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../login/view/login_page.dart';
import '../../../theme/app_colors.dart';
import '../../admin_navigation.dart';
import '../../admin_shell/cubit/admin_shell_cubit.dart';
import '../../admin_shell/cubit/admin_shell_state.dart';

/// A dynamic menu screen for admin modules. Items can be dragged from here
/// to the bottom nav bar to customize the workspace.
class MoreView extends StatelessWidget {
  const MoreView({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowestLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.outlineLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorLight,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminShellCubit, AdminShellState>(
      builder: (context, state) {
        final tabs = state.moreTabs;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  ...List.generate(tabs.length, (index) {
                    final tab = tabs[index];
                    final info = AdminTabInfo.all[tab]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LongPressDraggable<AdminTab>(
                        key: ValueKey('more_drag_${tab.name}'),
                        data: tab,
                        delay: const Duration(milliseconds: 500),
                        dragAnchorStrategy: (draggable, context, position) {
                          return Offset(
                            MediaQuery.of(context).size.width / 8,
                            30,
                          );
                        },
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            height: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkTeal.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.92,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        info.activeIcon,
                                        color: AppColors.darkTeal,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        info.label,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.2,
                          child: _MoreMenuItem(
                            icon: info.icon,
                            title: info.label,
                            subtitle: info.subtitle,
                            onTap: () {},
                          ),
                        ),
                        child: _MoreMenuItem(
                          icon: info.icon,
                          title: info.label,
                          subtitle: info.subtitle,
                          onTap: () => goToAdminTab(context, tab),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _MoreMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    iconColor: AppColors.errorLight,
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowestLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariantLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor?.withOpacity(0.1) ??
                      AppColors.surfaceContainerLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariantLight,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.outlineLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
