import 'package:flutter/material.dart';

import '../../../../core/widgets/user_avatar.dart';

class HeaderOverlay extends StatelessWidget {
  const HeaderOverlay({
    super.key,
    required this.partyName,
    required this.onPanicTap,
    required this.onPartyTap,
    required this.onAvatarTap,
  });

  final String partyName;
  final VoidCallback onPanicTap;
  final VoidCallback onPartyTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // botão de panico
            SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                heroTag: 'panic',
                backgroundColor: Colors.red.shade600,
                onPressed: onPanicTap,
                child: const Icon(Icons.emergency_share, size: 28),
              ),
            ),

            // seletor de gp dinamico
            Flexible(
              fit: FlexFit.loose,
              child: Center(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: onPartyTap,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 58),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                partyName,
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '|',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.qr_code_2_rounded, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // avatar do perfil
            InkResponse(
              onTap: onAvatarTap,
              radius: 34,
              child: const UserAvatar(
                radius: 30,
                backgroundColor: Color(0xFFCBD5E1),
                iconColor: Colors.white,
                iconSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
