import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_shell/cubit/admin_shell_cubit.dart';

enum AdminTab { dashboard, verification, users, complaints, bookings }

void goToAdminTab(BuildContext context, AdminTab tab) {
  /*if (tab == AdminTab.bookings) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Bookings management is coming soon.'),
        ),
      );
    return;
  }*/

  context.read<AdminShellCubit>().selectTab(tab);
}