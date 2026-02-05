import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Para formatação limpa
import 'bloco_selection_page.dart';

class PartyEvent {
  final String title;
  final String time;
  final String location;
  final IconData icon;
  PartyEvent({required this.title, required this.time, required this.location, this.icon = Icons.celebration});
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

  // 🚀 Definindo o Domínio: Carnaval 2026
  final DateTime _inicioFevereiro = DateTime.utc(2026, 2, 1);
  final DateTime _fimFevereiro = DateTime.utc(2026, 2, 28);
  final DateTime _sextaCarnaval = DateTime.utc(2026, 2, 13);

  Map<DateTime, List<PartyEvent>> _events = {};
  bool _isLoading = true;
  
  // 🚀 O foco deve começar em Fevereiro de 2026
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
      if (size > 0.6 && _calendarFormat == tc.CalendarFormat.week) {
        setState(() => _calendarFormat = tc.CalendarFormat.month);
      } else if (size <= 0.6 && _calendarFormat == tc.CalendarFormat.month) {
        setState(() => _calendarFormat = tc.CalendarFormat.week);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ScheduleSheetPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idParty != widget.idParty) {
      setState(() => _isLoading = true);
      _fetchPartyEvents();
    }
  }

  Future<void> _fetchPartyEvents() async {
    try {
      final response = await _supabase
          .from('Party_Bloco')
          .select('Bloco ( id, nome, bairro, rua, horaInicio )')
          .eq('idParty', widget.idParty);

      final Map<DateTime, List<PartyEvent>> loadedEvents = {};

      for (var row in response as List) {
        final bloco = row['Bloco'];
        if (bloco == null) continue;

        final DateTime start = DateTime.parse(bloco['horaInicio']).toLocal();
        final dateKey = DateTime.utc(start.year, start.month, start.day);

        loadedEvents.putIfAbsent(dateKey, () => []).add(
          PartyEvent(
            title: bloco['nome'] ?? 'Bloco',
            time: DateFormat("HH:mm").format(start), // Formatação vinda do intl
            location: "${bloco['bairro'] ?? ''}",
          ),
        );
      }

      if (mounted) {
        setState(() {
          _events = loadedEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<PartyEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      controller: _controller,
      initialChildSize: 0.28,
      minChildSize: 0.12,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.12, 0.28, 0.6, 0.92],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 5)],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHandle(),
                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      // 🚀 AlwaysScrollable garante que o scroll funcione mesmo com pouca lista
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _isLoading 
                            ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                            : tc.TableCalendar<PartyEvent>(
                                locale: 'pt_BR',
                                // 🚀 RESTRICÃO PARA FEVEREIRO 2026
                                firstDay: _inicioFevereiro,
                                lastDay: _fimFevereiro,
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) => tc.isSameDay(_selectedDay, day),
                                calendarFormat: _calendarFormat,
                                availableGestures: tc.AvailableGestures.horizontalSwipe, 
                                eventLoader: _getEventsForDay,
                                headerStyle: const tc.HeaderStyle(
                                  formatButtonVisible: false, 
                                  titleCentered: true,
                                  // Como só tem um mês, removemos as setas de navegação
                                  leftChevronVisible: false,
                                  rightChevronVisible: false,
                                ),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                                },
                              ),
                        ),
                        const SliverToBoxAdapter(child: Divider(height: 1)),
                        _buildDynamicEventList(),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  ),
                ],
              ),
              
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  backgroundColor: Colors.deepPurple,
                  elevation: 6,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocoSelectionPage(idParty: widget.idParty),
                      ),
                    );
                    _fetchPartyEvents();
                  },
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: () {
        double target = _controller.size > 0.28 ? 0.28 : 0.92;
        _controller.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 45, height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicEventList() {
    final events = _getEventsForDay(_selectedDay ?? _sextaCarnaval);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (_isLoading) return const SizedBox();
          if (events.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text("Nenhum bloco agendado", style: TextStyle(color: Colors.grey))),
            );
          }
          final event = events[index];
          return ListTile(
            leading: Icon(event.icon, color: Colors.deepPurple),
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text("${event.time} • ${event.location}"),
          );
        },
        childCount: _isLoading ? 0 : (events.isEmpty ? 1 : events.length),
      ),
    );
  }
}