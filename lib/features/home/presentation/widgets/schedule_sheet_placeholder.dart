import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 
import 'bloco_selection_page.dart';

class PartyEvent {
  final int id; 
  final String title;
  final String time;
  final String location;
  final IconData icon;
  int likes;
  int dislikes;
  String? myVote;

  PartyEvent({
    required this.id, required this.title, required this.time, 
    required this.location, required this.likes, required this.dislikes,
    this.myVote, this.icon = Icons.celebration
  });
}

class ScheduleSheetPlaceholder extends StatefulWidget {
  final int idParty; 
  const ScheduleSheetPlaceholder({super.key, required this.idParty});
  @override
  State<ScheduleSheetPlaceholder> createState() => _ScheduleSheetPlaceholderState();
}

class _ScheduleSheetPlaceholderState extends State<ScheduleSheetPlaceholder> {
  final _supabase = Supabase.instance.client;
  final DraggableScrollableController _controller = DraggableScrollableController();

  final DateTime _inicioFevereiro = DateTime.utc(2026, 2, 1);
  final DateTime _fimFevereiro = DateTime.utc(2026, 2, 28);
  final DateTime _sextaCarnaval = DateTime.utc(2026, 2, 13);
  
  final List<Color> _carnivalColors = [
    const Color(0xFFFF1493), const Color(0xFF00BFFF), const Color(0xFFFFD700), 
    const Color(0xFFFF8C00), const Color(0xFF9400D3), const Color(0xFF00FA9A), 
  ];

  // 🌈 Lógica de 7 cores por coluna
  Color _getWeekdayColor(DateTime date) {
    switch (date.weekday) {
      case DateTime.sunday: return const Color(0xFFFF1493); 
      case DateTime.monday: return const Color(0xFF00BFFF); 
      case DateTime.tuesday: return const Color(0xFF9400D3); 
      case DateTime.wednesday: return const Color(0xFF00A36C); 
      case DateTime.thursday: return const Color(0xFFFF8C00); 
      case DateTime.friday: return const Color(0xFF4169E1); 
      case DateTime.saturday: return const Color(0xFFC71585); 
      default: return Colors.black;
    }
  }

  Map<DateTime, List<PartyEvent>> _events = {};
  bool _isLoading = true;
  bool _showFab = false; 
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  tc.CalendarFormat _calendarFormat = tc.CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _focusedDay = _sextaCarnaval;
    _selectedDay = _sextaCarnaval;
    _fetchPartyEvents();
    _controller.addListener(() {
      if (!mounted) return;
      double size = _controller.size;
      if (size > 0.6 && _calendarFormat == tc.CalendarFormat.week) setState(() => _calendarFormat = tc.CalendarFormat.month);
      else if (size <= 0.6 && _calendarFormat == tc.CalendarFormat.month) setState(() => _calendarFormat = tc.CalendarFormat.week);
      if (size > 0.3 && !_showFab) setState(() => _showFab = true);
      else if (size <= 0.3 && _showFab) setState(() => _showFab = false);
      setState(() {});
    });
  }

  Future<void> _fetchPartyEvents() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final response = await _supabase.from('Party_Bloco').select('id, likes, dislikes, Bloco ( id, nome, bairro, rua, horaInicio ), Bloco_Votos ( voto_tipo )').eq('idParty', widget.idParty).eq('Bloco_Votos.user_id', user.id);
      final Map<DateTime, List<PartyEvent>> loadedEvents = {};
      for (var row in response as List) {
        final bloco = row['Bloco'];
        if (bloco == null) continue;
        final DateTime start = DateTime.parse(bloco['horaInicio']).toLocal();
        loadedEvents.putIfAbsent(DateTime.utc(start.year, start.month, start.day), () => []).add(PartyEvent(
          id: row['id'], title: bloco['nome'] ?? 'Bloco', time: DateFormat("HH:mm").format(start), location: "${bloco['bairro'] ?? ''}",
          likes: row['likes'] ?? 0, dislikes: row['dislikes'] ?? 0, myVote: (row['Bloco_Votos'] as List).isNotEmpty ? row['Bloco_Votos'][0]['voto_tipo'] : null,
        ));
      }
      if (mounted) setState(() { _events = loadedEvents; _isLoading = false; });
    } catch (e) { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _vote(PartyEvent event, String tipo) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      if (event.myVote == tipo) {
        await _supabase.from('Bloco_Votos').delete().match({'user_id': user.id, 'party_bloco_id': event.id});
      } else {
        await _supabase.from('Bloco_Votos').upsert({'user_id': user.id, 'party_bloco_id': event.id, 'voto_tipo': tipo}, onConflict: 'user_id,party_bloco_id');
      }
      await _fetchPartyEvents(); 
    } catch (e) { debugPrint("Erro: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 Lógica de Minimização (Ajustada para o novo tamanho menor)
    bool isMinimized = _controller.isAttached && _controller.size <= 0.08;

    return DraggableScrollableSheet(
      expand: false, 
      controller: _controller,
      initialChildSize: 0.08, // 🛠️ Diminuído para dar destaque ao mapa
      minChildSize: 0.08, 
      maxChildSize: 0.92, 
      snap: true,
      snapSizes: const [0.08, 0.15, 0.6, 0.92],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 5)]),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHandle(),
                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      slivers: [
                        if (isMinimized)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text("Calendário de Eventos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple))),
                          )
                        else ...[
                          SliverToBoxAdapter(
                            child: _isLoading ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                            : tc.TableCalendar<PartyEvent>(
                                locale: 'pt_BR', firstDay: _inicioFevereiro, lastDay: _fimFevereiro, focusedDay: _focusedDay,
                                selectedDayPredicate: (day) => tc.isSameDay(_selectedDay, day), calendarFormat: _calendarFormat,
                                availableGestures: tc.AvailableGestures.horizontalSwipe, 
                                eventLoader: (day) => _events[DateTime.utc(day.year, day.month, day.day)] ?? [],
                                calendarBuilders: tc.CalendarBuilders<PartyEvent>(
                                  dowBuilder: (context, day) {
                                    final text = DateFormat.E('pt_BR').format(day);
                                    return Center(child: Text(text, style: TextStyle(color: _getWeekdayColor(day), fontWeight: FontWeight.bold, fontSize: 12)));
                                  },
                                  defaultBuilder: (context, day, focusedDay) {
                                    return Center(child: Text('${day.day}', style: TextStyle(color: _getWeekdayColor(day), fontWeight: FontWeight.w600)));
                                  },
                                  todayBuilder: (context, day, focusedDay) {
                                    return Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: _getWeekdayColor(day).withOpacity(0.15), shape: BoxShape.circle), child: Center(child: Text('${day.day}', style: TextStyle(color: _getWeekdayColor(day), fontWeight: FontWeight.bold))));
                                  },
                                  selectedBuilder: (context, day, focusedDay) {
                                    return Container(
                                      margin: const EdgeInsets.all(4), 
                                      decoration: BoxDecoration(color: _getWeekdayColor(day), shape: BoxShape.circle), 
                                      child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                                    );
                                  },
                                  // 📍 Marcador de Bloco Corrigido: Cor aparente e tamanho maior
                                  markerBuilder: (context, day, events) {
                                    if (events.isEmpty) return null;
                                    return Positioned(
                                      bottom: 5, 
                                      child: Container(
                                        width: 6, 
                                        height: 6, 
                                        decoration: const BoxDecoration(
                                          color: Colors.deepPurple, // 🚀 Roxo para máxima visibilidade
                                          shape: BoxShape.circle
                                        )
                                      )
                                    );
                                  },
                                ),
                                headerStyle: const tc.HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
                                onDaySelected: (selectedDay, focusedDay) => setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }),
                              ),
                          ),
                          const SliverToBoxAdapter(child: Divider(height: 1)),
                          _buildListSliver(),
                          const SliverToBoxAdapter(child: SizedBox(height: 120)),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(bottom: 24, right: 24, child: AnimatedScale(scale: _showFab ? 1.0 : 0.0, duration: const Duration(milliseconds: 250), child: FloatingActionButton.extended(backgroundColor: Colors.deepPurple, onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => BlocoSelectionPage(idParty: widget.idParty))); _fetchPartyEvents(); }, label: const Text("Novo Bloco", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), icon: const Icon(Icons.add, color: Colors.white)))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListSliver() {
    final events = _events[DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];
    return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
      if (events.isEmpty) return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text("Nenhum bloco agendado")));
      final event = events[index];
      final Color themeColor = _carnivalColors[index % _carnivalColors.length];
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: themeColor.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(children: [Container(width: 6, color: themeColor), Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [CircleAvatar(backgroundColor: themeColor.withOpacity(0.1), child: Icon(event.icon, color: themeColor, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("${event.time} • ${event.location}", style: TextStyle(color: Colors.grey[600], fontSize: 13))])), Row(children: [_voteBtn(event, 'like', "❤️", event.likes, themeColor), const SizedBox(width: 12), _voteBtn(event, 'dislike', "👎", event.dislikes, Colors.orange)])])))],),
          ),
        ),
      );
    }, childCount: events.isEmpty ? 1 : events.length));
  }

  Widget _voteBtn(PartyEvent event, String tipo, String emoji, int count, Color activeColor) {
    bool isSel = event.myVote == tipo;
    return GestureDetector(onTap: () => _vote(event, tipo), child: Column(children: [AnimatedScale(scale: isSel ? 1.3 : 1.0, duration: const Duration(milliseconds: 200), child: Opacity(opacity: (event.myVote != null && !isSel) ? 0.3 : 1.0, child: Text(emoji, style: const TextStyle(fontSize: 18)))), Text("$count", style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal, fontSize: 11, color: isSel ? activeColor : Colors.black54))]));
  }

  Widget _buildHandle() => GestureDetector(onTap: () => _controller.animateTo(_controller.size > 0.28 ? 0.08 : 0.92, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), color: Colors.transparent, child: Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))))));
}