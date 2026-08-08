import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/cubit/locale_cubit.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/login/login.dart';
import 'package:frontend/role_selection/role_selection.dart';
import 'package:frontend/splash/splash.dart';
import 'package:frontend/welcome_screen/welcome_screen.dart';
import 'package:frontend/admin/caregiver_verification/caregiver_verification.dart';
import 'package:frontend/admin/caregiver_review/caregiver_review.dart';
import 'package:frontend/admin/user_management/user_management.dart';
import 'package:frontend/admin/complaint_management/complaint_management.dart';
import 'package:frontend/admin/complaint_detail/complaint_detail.dart';
import 'package:frontend/admin/dashboard/dashboard.dart';
import 'package:frontend/admin/admin_shell/admin_shell.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocaleCubit(),
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          theme: ThemeData(
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
            ),
          ),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SplashPage(
            duration: const Duration(milliseconds: 3000),
            nextScreen: Builder(
              builder: (context) => WelcomeScreenPage(
                onGetStarted: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const RoleSelectionPage(),
                    ),
                  );
                },
                onLogin: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                onContactSupport: () {
                  // TODO: open support link
                },
                onLanguageToggle: () => context.read<LocaleCubit>().toggleLocale(),
              ),
            ),
          ),
        );
      },
    );
  }
}
