import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 

class BlocoSelectionPage extends StatefulWidget {
  final int idParty;
  const BlocoSelectionPage({super.key, required this.idParty});

  @override
  State<BlocoSelectionPage> createState() => _BlocoSelectionPageState();
}

class _BlocoSelectionPageState extends State<BlocoSelectionPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _allBlocos = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchBlocos();
  }

  Future<void> _fetchBlocos() async {
    try {
      final data = await _supabase.from('Bloco').select('*').order('nome');
      if (mounted) {
        setState(() {
          _allBlocos = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkBlocoToParty(int idBloco) async {
    try {
      await _supabase.from('Party_Bloco').insert({
        'idParty': widget.idParty,
        'idBloco': idBloco,
      });
      
      if (mounted) Navigator.pop(context);
      
    } on PostgrestException catch (e) {
      // erro de chave unica
      if (e.code == '23505') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Este bloco já está na sua party!"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // tratamento para outros erros de banco (ex: RLS, Timeout)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro no banco: ${e.message}")),
          );
        }
      }
    } catch (e) {
      // tratamento para erros inesperados
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ocorreu um erro inesperado ao vincular.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Bloco")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _allBlocos.length,
            itemBuilder: (context, index) {
              final bloco = _allBlocos[index];

              String dataFormatada = "Data não informada";
              if (bloco['horaInicio'] != null) {
                final DateTime dt = DateTime.parse(bloco['horaInicio']);
                dataFormatada = DateFormat("dd/MM 'às' HH:mm", "pt_BR").format(dt);
              }

              return ListTile(
                title: Text(
                  bloco['nome'] ?? 'Sem nome', 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                subtitle: Text(
                  "${bloco['bairro'] ?? '-'} • $dataFormatada", // Visual limpo
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: const Icon(Icons.add_circle_outline, color: Colors.deepPurple),
                onTap: () => _linkBlocoToParty(bloco['id']),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        label: const Text("Novo Bloco", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.create, color: Colors.white),
        onPressed: _isSaving ? null : () => _showCreateBlocoDialog(),
      ),
    );
  }

  void _showCreateBlocoDialog() {
    final nomeCtrl = TextEditingController();
    final bairroCtrl = TextEditingController();
    DateTime? dataSelecionada;
    TimeOfDay? horaInicio;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Cadastrar Novo Bloco"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeCtrl, 
                  decoration: const InputDecoration(labelText: "Nome (Obrigatório)")
                ),
                TextField(
                  controller: bairroCtrl, 
                  decoration: const InputDecoration(labelText: "Bairro")
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                  title: Text(dataSelecionada == null 
                    ? "Escolher Data" 
                    : DateFormat("dd/MM/yyyy").format(dataSelecionada!)),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2026, 2, 13),
                      firstDate: DateTime(2026, 2, 13),
                      lastDate: DateTime(2026, 2, 28),
                    );
                    if (p != null) setDialogState(() => dataSelecionada = p);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                  title: Text(horaInicio == null 
                    ? "Escolher Hora" 
                    : horaInicio!.format(context)),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (t != null) setDialogState(() => horaInicio = t);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(dialogContext), 
              child: const Text("Cancelar")
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: _isSaving ? null : () async {
                if (nomeCtrl.text.isEmpty || dataSelecionada == null || horaInicio == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preencha todos os campos obrigatórios!")),
                  );
                  return;
                }

                setDialogState(() => _isSaving = true);

                try {
                  final dt = DateTime(
                    dataSelecionada!.year, dataSelecionada!.month, dataSelecionada!.day, 
                    horaInicio!.hour, horaInicio!.minute
                  );
                  
                  final response = await _supabase.from('Bloco').insert({
                    'nome': nomeCtrl.text,
                    'bairro': bairroCtrl.text,
                    'horaInicio': dt.toIso8601String(),
                  }).select().single();

                  await _linkBlocoToParty(response['id']);

                  if (context.mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro no Banco: $e")),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
              },
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}