import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../features/auth/presentation/pages/email_register_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/terms_screen.dart';
import '../features/auth/presentation/pages/welcome_screen.dart';
import 'shell/app_shell.dart';
import 'router/app_routes.dart';
import 'router/auth_gate.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeral Junto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: AppTheme.colorScheme,
        scaffoldBackgroundColor: AppColors.surface,
        inputDecorationTheme: AppTheme.inputDecorationTheme,
        textTheme: AppTheme.textTheme,
        elevatedButtonTheme: AppTheme.elevatedButtonTheme,
        outlinedButtonTheme: AppTheme.outlinedButtonTheme,
      ),
      routes: {
        AppRoutes.root: (_) => const AuthGate(),
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.emailRegister: (_) => const EmailRegisterScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.home: (_) => const AppShell(),
        AppRoutes.terms: (_) => const TermsScreen(),
      },
      initialRoute: AppRoutes.root,
    );
  }
}
