import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_screen.dart'; 

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Enquanto o Supabase inicializa a conexão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // ✅ Usuário logado: Pode ir para a Home (que vai checar as parties)
          return const HomePage();
        } else {
          return const LoginScreen(); 
        }
      },
    );
  }
}