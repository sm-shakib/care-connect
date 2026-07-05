import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/login/login.dart';
import 'package:frontend/role_selection/role_selection.dart';
import 'package:frontend/splash/splash.dart';
import 'package:frontend/welcome_screen/welcome_screen.dart';

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
          color: Colors.white,
        ),
      ),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SplashPage(
        duration: const Duration(milliseconds: 3000),
        nextScreen: Builder(
          builder: (context) => WelcomeScreenPage(
            onGetStarted: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionPage(),
                ),
              );
            },
            onLogin: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage(
                  onSignUp: () { /* TODO */ },
                )),
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