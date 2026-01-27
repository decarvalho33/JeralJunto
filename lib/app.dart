import 'package:flutter/material.dart';

import 'core/constants.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/email_register_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'routes.dart';

class App extends StatelessWidget {
  const App({super.key});

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
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.emailRegister: (_) => const EmailRegisterScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
      },
      initialRoute: AppRoutes.root,
    );
  }
}
