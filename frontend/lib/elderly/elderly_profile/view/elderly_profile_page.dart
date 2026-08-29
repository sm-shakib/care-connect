import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/elderly/data/repositories/elder_repository.dart';
import 'package:frontend/elderly/elderly_profile/cubit/elderly_profile_cubit.dart';
import 'package:frontend/elderly/elderly_profile/view/elderly_profile_view.dart';
import 'package:frontend/login/view/login_page.dart';

class ElderlyProfilePage extends StatelessWidget {
  const ElderlyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ElderlyProfileCubit(
        ElderRepository(ApiClient()),
      ),
      child: ElderlyProfileView(
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
