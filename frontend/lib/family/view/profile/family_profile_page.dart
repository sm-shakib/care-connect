import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/family/family_profile/cubit/family_profile_cubit.dart';
import 'package:frontend/family/family_profile/view/family_profile_view.dart';
import 'package:frontend/login/view/login_page.dart';

class FamilyProfilePage extends StatelessWidget {
  const FamilyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilyProfileCubit(),
      child: FamilyProfileView(
        showTopBar: false,
        onLogOut: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
      ),
    );
  }
}
