import 'package:flutter/material.dart';
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

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale _locale = const Locale('en');

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('bn')
          : const Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      locale: _locale,
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
                  builder: (context) => const ComplaintManagementPage(),//LoginPage(),
                ),
              );
            },
            onContactSupport: () {
              // TODO: open support link
            },
            onLanguageToggle: _toggleLocale,
          ),
        ),
      ),
    );
  }
}