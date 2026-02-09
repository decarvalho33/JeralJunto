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

  final List<Color> _carnivalColors = [
    const Color(0xFFFF1493), // Rosa Choque
    const Color(0xFF00BFFF), // Azul Elétrico
    const Color(0xFFFFD700), // Amarelo Ouro
    const Color(0xFFFF8C00), // Laranja Vibrante
    const Color(0xFF9400D3), // Roxo
    const Color(0xFF00FA9A), // Verde Primavera
  ];

  @override
  void initState() {
    super.initState();
    _fetchBlocos();
  }

  // Busca a lista global de blocos cadastrados
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

  // Cria o vínculo N:N entre a Party e o Bloco
  Future<void> _linkBlocoToParty(int idBloco) async {
    try {
      await _supabase.from('Party_Bloco').insert({
        'idParty': widget.idParty,
        'idBloco': idBloco,
      });
      if (mounted) Navigator.pop(context); 
    } on PostgrestException catch (e) {
      if (e.code == '23505' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Este bloco já está na sua party!"), 
            backgroundColor: Colors.orange
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao vincular: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Adicionar Bloco", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _allBlocos.length,
            itemBuilder: (context, index) {
              final bloco = _allBlocos[index];
              final Color themeColor = _carnivalColors[index % _carnivalColors.length];

              String dataFormatada = "Data não definida";
              if (bloco['horaInicio'] != null) {
                final DateTime dt = DateTime.parse(bloco['horaInicio']);
                dataFormatada = DateFormat("dd/MM 'às' HH:mm", "pt_BR").format(dt);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16), 
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 6, color: themeColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bloco['nome'] ?? 'Sem nome',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${bloco['bairro'] ?? '-'} • ${bloco['rua'] ?? ''}",
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    dataFormatada,
                                    style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _linkBlocoToParty(bloco['id']),
                            child: Container(
                              width: 50,
                              color: themeColor.withOpacity(0.05),
                              child: Icon(Icons.add_circle_outline, color: themeColor, size: 28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        label: const Text("Novo Bloco", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Cadastrar Novo Bloco"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: "Nome (Obrigatório)")),
                TextField(controller: bairroCtrl, decoration: const InputDecoration(labelText: "Bairro")),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                  title: Text(dataSelecionada == null ? "Data" : DateFormat("dd/MM").format(dataSelecionada!)),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2026, 2, 13),
                      firstDate: DateTime(2026, 2, 13),
                      lastDate: DateTime(2026, 2, 21),
                    );
                    if (p != null) setDialogState(() => dataSelecionada = p);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                  title: Text(horaInicio == null ? "Hora" : horaInicio!.format(context)),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (t != null) setDialogState(() => horaInicio = t);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: const StadiumBorder()),
              onPressed: _isSaving ? null : () async {
                if (nomeCtrl.text.isEmpty || dataSelecionada == null || horaInicio == null) return;
                setDialogState(() => _isSaving = true);
                try {
                  final dt = DateTime(dataSelecionada!.year, dataSelecionada!.month, dataSelecionada!.day, horaInicio!.hour, horaInicio!.minute);
                  final response = await _supabase.from('Bloco').insert({
                    'nome': nomeCtrl.text,
                    'bairro': bairroCtrl.text,
                    'horaInicio': dt.toIso8601String(),
                  }).select().single();
                  await _linkBlocoToParty(response['id']);
                  if (context.mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
              },
              child: const Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}