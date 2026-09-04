import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/cubit/locale_cubit.dart';
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
