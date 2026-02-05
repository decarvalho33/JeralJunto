import 'package:flutter/material.dart';

class HeaderOverlay extends StatelessWidget {
  const HeaderOverlay({
    super.key,
    required this.partyName, // ✅ Novo parâmetro obrigatório
    required this.onPartyTap,
    required this.onAvatarTap,
  });

  final String partyName; // ✅ Declaração da variável
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
            // Botão de Pânico
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
            
            // Seletor de Grupo Dinâmico
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onPartyTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Text(
                    partyName, // ✅ Agora exibe o nome que vem do banco de dados
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            
            // Avatar do Perfil
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