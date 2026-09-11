import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/cubit/locale_cubit.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/core/services/sos_alert_service.dart';
import 'package:frontend/elderly/dashboard/elderly_dashboard.dart';
import 'package:frontend/caregiver/caregiver_dashboard/caregiver_dashboard.dart';
import 'package:frontend/caregiver/caregiver_pending/caregiver_pending.dart';
import 'package:frontend/family/view/family_dashboard_page.dart';
import 'package:frontend/admin/admin_shell/view/admin_shell_page.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/login/login.dart';
import 'package:frontend/role_selection/role_selection.dart';
import 'package:frontend/shared/chat/chat.dart';
import 'package:frontend/shared/medicine/alarm/medicine_alarm_service.dart';
import 'package:frontend/splash/splash.dart';
import 'package:frontend/welcome_screen/welcome_screen.dart';

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

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    MedicineAlarmService.instance.initialize(_navigatorKey);
    IncomingCallService.instance.initialize(_navigatorKey);
    unawaited(SosAlertService.instance.initialize(_navigatorKey));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
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
            nextScreen: FutureBuilder<Widget?>(
              future: _getInitialScreen(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return snapshot.data ?? _buildWelcomeScreen(context);
              },
            ),
          ),
        );
      },
    );
  }

  Future<Widget?> _getInitialScreen() async {
    final authRepo = AuthRepository();
    final loggedIn = await authRepo.isLoggedIn();
    if (!loggedIn) return null;

    final role = await authRepo.getUserRole();
    final status = await authRepo.getUserStatus();

    switch (role) {
      case 'admin':
        return const AdminShellPage();
      case 'elder':
        return const ElderlyDashboardPage();
      case 'caregiver':
        if (status == 'verified') {
          return const CaregiverDashboardPage();
        } else {
          return const CaregiverPendingPage();
        }
      case 'family':
        return const FamilyDashboardPage();
      default:
        return null;
    }
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    return WelcomeScreenPage(
      onGetStarted: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const RoleSelectionPage(),
          ),
        );
      },
      onLogin: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const LoginPage(),
          ),
        );
      },
      onContactSupport: () {
        // TODO: open support link
      },
      onLanguageToggle: () => context.read<LocaleCubit>().toggleLocale(),
    );
  }
}
