import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/pending_party_invite.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/party/presentation/pages/join_party_screen.dart';
import '../shell/app_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session != null) {
          final pendingCode = PendingPartyInvite.peek();
          if (pendingCode != null) {
            return JoinPartyScreen(prefilledCode: pendingCode, autoJoin: true);
          }
          return const AppShell();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}
