// home_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Certifique-se de que o caminho da PartyScreen está correto
import '../../../party/presentation/pages/party_screen.dart'; 
import '../widgets/header_overlay.dart';
import '../widgets/map_background_placeholder.dart';
import '../widgets/schedule_sheet_placeholder.dart';
import '../widgets/no_party_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _userParties = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    try {
      final user = _supabase.auth.currentUser;
      final data = await _supabase
          .from('Party_Usuario')
          .select('Party ( id, nome )')
          .eq('idUsuario', user?.id ?? '');

      if (mounted) {
        setState(() {
          _userParties = (data as List).map((it) => it['Party'] as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica para quando o usuário tiver 2 parties (ver explicação abaixo)
  void _nextParty() {
    if (_userParties.length < 2) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _userParties.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_userParties.isEmpty) return NoPartyOverlay(onRefresh: _loadParties);

    final currentParty = _userParties[_currentIndex];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MapBackgroundPlaceholder(),
          Align(
            alignment: Alignment.bottomCenter,
            child: ScheduleSheetPlaceholder(idParty: currentParty['id']),
          ),
          Positioned(
            left: 0, right: 0, top: 0,
            child: HeaderOverlay(
              partyName: currentParty['nome'],
              // 🚀 VOLTOU A NAVEGAÇÃO: Agora abre a tela de parties
              onPartyTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PartyScreen()),
                );
                _loadParties(); // Recarrega caso o usuário tenha saído/entrado em grupos
              },
              onAvatarTap: () { /* Menu de Perfil */ },
            ),
          ),
        ],
      ),
    );
  }
}