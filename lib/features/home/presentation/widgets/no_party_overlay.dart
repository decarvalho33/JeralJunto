import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoPartyOverlay extends StatelessWidget {
  final VoidCallback onRefresh;

  const NoPartyOverlay({
    super.key, 
    required this.onRefresh,
  });

  // mostrar o diálogo de entrada
  void _showJoinDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final supabase = Supabase.instance.client;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Entrar em uma Party"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            hintText: "Ex: CARNA-2026",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () async {
              try {
                final party = await supabase
                    .from('Party')
                    .select('id')
                    .eq('codigo', codeController.text.toUpperCase())
                    .single();

                await supabase.from('Party_Usuario').insert({
                  'idParty': party['id'],
                  'idUsuario': supabase.auth.currentUser!.id,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  onRefresh(); // chama a função que recarrega a Home
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Código inválido ou erro de conexão.")),
                );
              }
            },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_add_outlined, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                "Jeral Junto",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text(
                "Você ainda não faz parte de nenhum grupo. Comece criando o seu ou entre no de seus amigos.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () { /* Lógica para Criar Party provavelmente eduardo */ },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Criar Minha Party", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _showJoinDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurple, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Tenho um Código", style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}