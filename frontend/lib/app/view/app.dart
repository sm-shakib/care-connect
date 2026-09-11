import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/cubit/locale_cubit.dart';
import 'package:frontend/core/repositories/auth_repository.dart';
import 'package:frontend/core/services/sos_alert_service.dart';
import 'package:frontend/elderly/dashboard/elderly_dashboard.dart';
import 'package:frontend/caregiver/caregiver_dashboard/caregiver_dashboard.dart';
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
  // Lets MedicineAlarmService push the full-screen alarm page on a
  // notification tap, even from a cold start with no other route mounted
  // yet.
  final _navigatorKey = GlobalKey<NavigatorState>();
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: sets up notification channels/permissions. Actual
    // alarms are only ever scheduled once an elder's medicines load
    // (see MedicineCubit), so this is a no-op for other roles.
    MedicineAlarmService.instance.initialize(_navigatorKey);
    // Lets an incoming call be caught (and its full-screen ring UI pushed)
    // from anywhere in the app, not just while a conversation is open.
    IncomingCallService.instance.initialize(_navigatorKey);
    // Lets a family member or caregiver be notified the moment someone
    // they care for presses SOS, wherever they are in the app — including
    // pushing the full-screen SosAlertScreen via the same navigator key.
    unawaited(SosAlertService.instance.initialize(_navigatorKey));

    _checkInitialScreen();
  }

  Future<void> _checkInitialScreen() async {
    final authRepo = AuthRepository();
    final loggedIn = await authRepo.isLoggedIn();

    if (!mounted) return;

    if (!loggedIn) {
      setState(() {
        _initialScreen = _buildWelcomeScreen();
      });
      return;
    }

    final role = await authRepo.getUserRole();
    if (!mounted) return;

    setState(() {
      switch (role) {
        case 'admin':
          _initialScreen = const AdminShellPage();
          break;
        case 'elder':
          _initialScreen = const ElderlyDashboardPage();
          break;
        case 'caregiver':
          _initialScreen = const CaregiverDashboardPage();
          break;
        case 'family':
          _initialScreen = const FamilyDashboardPage();
          break;
        default:
          _initialScreen = _buildWelcomeScreen();
      }
    });
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
            nextScreen: _initialScreen ?? const Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return WelcomeScreenPage(
      onGetStarted: () {
        _navigatorKey.currentState?.push(
          MaterialPageRoute<void>(
            builder: (context) => const RoleSelectionPage(),
          ),
        );
      },
      onLogin: () {
        _navigatorKey.currentState?.push(
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
