import 'package:flutter/material.dart';

class HeaderOverlay extends StatelessWidget {
  const HeaderOverlay({
    super.key,
    required this.onPartyTap,
    required this.onAvatarTap,
    this.avatarUrl,
  });

  final VoidCallback onPartyTap;
  final VoidCallback onAvatarTap;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: FloatingActionButton(
              heroTag: 'panic',
              backgroundColor: Colors.red.shade600,
              onPressed: () {},
              child: const Icon(Icons.emergency_share, size: 32),
              ),
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: onPartyTap,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Grupo chique de xique-xique',
                        style:
                            TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.qr_code_2, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            InkResponse(
              onTap: onAvatarTap,
              radius: 32,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF22C55E),
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x6622C55E),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFCBD5E1),
                  backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: (avatarUrl == null || avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 26)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
