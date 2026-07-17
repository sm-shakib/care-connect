import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/user_management_cubit.dart';
import 'user_management_view.dart';

/// Route-level entry point for the admin User Management feature.
/// Provides [UserManagementCubit] and kicks off the initial load.
class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const UserManagementPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserManagementCubit()..loadUsers(),
      child: const UserManagementView(),
    );
  }
}