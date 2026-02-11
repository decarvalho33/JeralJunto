import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../pages/join_party_screen.dart';

class PartyDeepLinkHandler {
  const PartyDeepLinkHandler._();

  static Route<dynamic>? tryBuildRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null || name.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(name);
    if (uri == null) {
      return null;
    }

    if (uri.path != AppRoutes.joinParty) {
      return null;
    }

    final code = uri.queryParameters['code'];
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => JoinPartyScreen(
        prefilledCode: code,
        autoJoin: true,
      ),
    );
  }
}
