import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/party_invite.dart';
import '../pages/join_party_screen.dart';

class PartyDeepLinkHandler {
  const PartyDeepLinkHandler._();

  static String resolveInitialRoute() {
    final uri = Uri.base;
    if (!isJoinPartyUri(uri)) {
      return AppRoutes.root;
    }

    final code = extractJoinCodeFromInviteUri(uri);
    if (code == null) {
      return AppRoutes.joinParty;
    }
    return '${AppRoutes.joinParty}?code=$code';
  }

  static Route<dynamic>? tryBuildRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null || name.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(name);
    if (uri == null) {
      return null;
    }

    if (!isJoinPartyUri(uri)) {
      return null;
    }

    final code = extractJoinCodeFromInviteUri(uri);
    final autoJoin = code != null;
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => JoinPartyScreen(prefilledCode: code, autoJoin: autoJoin),
    );
  }
}
