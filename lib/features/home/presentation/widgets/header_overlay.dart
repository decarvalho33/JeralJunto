import 'package:flutter/material.dart';

class HeaderOverlay extends StatelessWidget {
  const HeaderOverlay({
    super.key,
    required this.onPartyTap,
    required this.onAvatarTap,
  });

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
            SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
              heroTag: 'panic',
              backgroundColor: Colors.red.shade600,
              onPressed: () {},
              child: const Icon(Icons.emergency_share, size: 28),
              ),
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onPartyTap,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Text(
                    'Grupo chique de xique-xique',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            InkResponse(
              onTap: onAvatarTap,
              radius: 26,
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFCBD5E1),
                child: Icon(Icons.person, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
