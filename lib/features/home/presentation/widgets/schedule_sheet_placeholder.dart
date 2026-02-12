import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../data/map_models.dart';
import '../providers/map_providers.dart';
import 'bloco_selection_page.dart';

class PartyEvent {
  final int id; // Party_Bloco.id
  final String title;
  final DateTime start;
  final DateTime? end;
  final String location;
  final IconData icon;
  int likes;
  int dislikes;
  String? myVote;

  PartyEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.location,
    required this.likes,
    required this.dislikes,
    this.end,
    this.myVote,
    this.icon = Icons.celebration,
  });
}

class EventVoteDetails {
  final List<MemberInfo> likes;
  final List<MemberInfo> dislikes;

  const EventVoteDetails({required this.likes, required this.dislikes});
}

class ScheduleSheetPlaceholder extends ConsumerStatefulWidget {
  final int idParty;
  const ScheduleSheetPlaceholder({super.key, required this.idParty});

  @override
  ConsumerState<ScheduleSheetPlaceholder> createState() =>
      _ScheduleSheetPlaceholderState();
}

class _ScheduleSheetPlaceholderState
    extends ConsumerState<ScheduleSheetPlaceholder> {
  final _supabase = Supabase.instance.client;
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  // Fevereiro 2026
  final DateTime _inicioFevereiro = DateTime(2026, 2, 1);
  final DateTime _fimFevereiro = DateTime(2026, 2, 28);
  final DateTime _sextaCarnaval = DateTime(2026, 2, 13);

  final List<Color> _carnivalColors = [
    const Color(0xFFFF1493),
    const Color(0xFF00BFFF),
    const Color(0xFFFFD700),
    const Color(0xFFFF8C00),
    const Color(0xFF9400D3),
    const Color(0xFF00FA9A),
  ];

  Color _getWeekdayColor(DateTime date) {
    switch (date.weekday) {
      case DateTime.sunday:
        return const Color(0xFFFF1493);
      case DateTime.monday:
        return const Color(0xFF00BFFF);
      case DateTime.tuesday:
        return const Color(0xFF9400D3);
      case DateTime.wednesday:
        return const Color(0xFF00A36C);
      case DateTime.thursday:
        return const Color(0xFFFF8C00);
      case DateTime.friday:
        return const Color(0xFF4169E1);
      case DateTime.saturday:
        return const Color(0xFFC71585);
      default:
        return Colors.black;
    }
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

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
      final size = _controller.size;

      final nextFormat = size > 0.6
          ? tc.CalendarFormat.month
          : tc.CalendarFormat.week;
      final nextShowFab = size > 0.3;

      if (nextFormat == _calendarFormat && nextShowFab == _showFab) return;

      setState(() {
        _calendarFormat = nextFormat;
        _showFab = nextShowFab;
      });
    });
  }

  Future<void> _fetchPartyEvents() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Ordena cronologicamente pelo horário de início do Bloco (tabela relacionada)
      final response = await _supabase
          .from('Party_Bloco')
          .select(
            'id, likes, dislikes, Bloco ( id, nome, bairro, rua, horaInicio, horaTermino ), Bloco_Votos ( voto_tipo )',
          )
          .eq('idParty', widget.idParty)
          .eq('Bloco_Votos.user_id', user.id)
          .order('horaInicio', referencedTable: 'Bloco', ascending: true)
          .order('id', ascending: true);

      final Map<DateTime, List<PartyEvent>> loadedEvents = {};

      for (final row in (response as List)) {
        final bloco = row['Bloco'];
        if (bloco == null) continue;

        final rawStart = bloco['horaInicio'];
        if (rawStart == null) continue;

        // OBS: horaInicio/Termino são timestamp without time zone.
        // Se você salva como hora "local", talvez seja melhor NÃO usar toLocal().
        // Mantive toLocal() como estava no seu código, mas se houver drift de dia/hora, remova.
        final DateTime start = DateTime.parse(rawStart).toLocal();

        final rawEnd = bloco['horaTermino'];
        final DateTime? end = rawEnd == null
            ? null
            : DateTime.parse(rawEnd).toLocal();

        final key = _dayKey(start);

        final votos = (row['Bloco_Votos'] as List?) ?? const [];
        final String? myVote = votos.isNotEmpty
            ? votos.first['voto_tipo'] as String?
            : null;

        loadedEvents
            .putIfAbsent(key, () => [])
            .add(
              PartyEvent(
                id: (row['id'] as num).toInt(),
                title: (bloco['nome'] ?? 'Bloco').toString(),
                start: start,
                end: end,
                location: "${bloco['bairro'] ?? ''}".trim(),
                likes: (row['likes'] ?? 0) as int,
                dislikes: (row['dislikes'] ?? 0) as int,
                myVote: myVote,
              ),
            );
      }

      // Segurança: garante ordem cronológica por dia
      for (final dayEvents in loadedEvents.values) {
        dayEvents.sort((a, b) => a.start.compareTo(b.start));
      }

      if (!mounted) return;
      setState(() {
        _events = loadedEvents;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _vote(PartyEvent event, String tipo) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      if (event.myVote == tipo) {
        await _supabase.from('Bloco_Votos').delete().match({
          'user_id': user.id,
          'party_bloco_id': event.id,
        });
      } else {
        await _supabase.from('Bloco_Votos').upsert({
          'user_id': user.id,
          'party_bloco_id': event.id,
          'voto_tipo': tipo,
        }, onConflict: 'user_id,party_bloco_id');
      }

      // MVP simples: refetch geral
      await _fetchPartyEvents();
    } catch (e) {
      debugPrint("Erro: $e");
    }
  }

  Future<EventVoteDetails> _fetchEventVoteDetails(int partyBlocoId) async {
    final members = await ref.read(partyMembersProvider(widget.idParty).future);
    final membersById = {for (final member in members) member.id: member};

    final response = await _supabase
        .from('Bloco_Votos')
        .select('user_id, voto_tipo')
        .eq('party_bloco_id', partyBlocoId);

    final likes = <MemberInfo>[];
    final dislikes = <MemberInfo>[];

    for (final row in (response as List)) {
      final userId = row['user_id'] as String?;
      final voteType = row['voto_tipo'] as String?;
      if (userId == null || userId.isEmpty || voteType == null) continue;

      final member =
          membersById[userId] ??
          MemberInfo(id: userId, name: 'Participante', avatarUrl: null);

      if (voteType == 'like') likes.add(member);
      if (voteType == 'dislike') dislikes.add(member);
    }

    likes.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    dislikes.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return EventVoteDetails(likes: likes, dislikes: dislikes);
  }

  Future<void> _openEventDetails(PartyEvent event, Color themeColor) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: FutureBuilder<EventVoteDetails>(
                future: _fetchEventVoteDetails(event.id),
                builder: (context, snapshot) {
                  return CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Detalhes do Bloco',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildEventCard(
                          event: event,
                          themeColor: themeColor,
                          canVote: false,
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      else if (snapshot.hasError)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'Não foi possível carregar os votos desse bloco.',
                              ),
                            ),
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: _buildVotersSection(
                            title: 'Votaram que vão ❤️',
                            users: snapshot.data?.likes ?? const [],
                            emptyText: 'Ninguém votou que vai ainda.',
                            accentColor: themeColor,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _buildVotersSection(
                            title: 'Deram dislike 👎',
                            users: snapshot.data?.dislikes ?? const [],
                            emptyText: 'Ninguém deu dislike ainda.',
                            accentColor: Colors.orange,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 28)),
                      ],
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMinimized = _controller.isAttached && _controller.size <= 0.08;

    return DraggableScrollableSheet(
      expand: false,
      controller: _controller,
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.08, 0.15, 0.6, 0.92],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 5),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHandle(),
                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        if (isMinimized)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                "Calendário de Eventos",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          SliverToBoxAdapter(
                            child: _isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : tc.TableCalendar<PartyEvent>(
                                    locale: 'pt_BR',
                                    firstDay: _inicioFevereiro,
                                    lastDay: _fimFevereiro,
                                    focusedDay: _focusedDay,
                                    selectedDayPredicate: (day) =>
                                        tc.isSameDay(_selectedDay, day),
                                    calendarFormat: _calendarFormat,
                                    availableGestures:
                                        tc.AvailableGestures.horizontalSwipe,
                                    eventLoader: (day) =>
                                        _events[_dayKey(day)] ?? [],
                                    calendarBuilders:
                                        tc.CalendarBuilders<PartyEvent>(
                                          dowBuilder: (context, day) {
                                            final text = DateFormat.E(
                                              'pt_BR',
                                            ).format(day);
                                            return Center(
                                              child: Text(
                                                text,
                                                style: TextStyle(
                                                  color: _getWeekdayColor(day),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          },
                                          defaultBuilder:
                                              (context, day, focusedDay) {
                                                return Center(
                                                  child: Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      color: _getWeekdayColor(
                                                        day,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                );
                                              },
                                          todayBuilder:
                                              (context, day, focusedDay) {
                                                return Container(
                                                  margin: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getWeekdayColor(
                                                      day,
                                                    ).withValues(alpha: 0.15),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${day.day}',
                                                      style: TextStyle(
                                                        color: _getWeekdayColor(
                                                          day,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                          selectedBuilder:
                                              (context, day, focusedDay) {
                                                return Container(
                                                  margin: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getWeekdayColor(
                                                      day,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${day.day}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                          markerBuilder:
                                              (context, day, events) {
                                                if (events.isEmpty) return null;
                                                return const Positioned(
                                                  bottom: 5,
                                                  child: SizedBox(
                                                    width: 6,
                                                    height: 6,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.deepPurple,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                    headerStyle: const tc.HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      titleTextStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    onDaySelected: (selectedDay, focusedDay) =>
                                        setState(() {
                                          _selectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                        }),
                                  ),
                          ),
                          const SliverToBoxAdapter(child: Divider(height: 1)),
                          _buildListSliver(),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 120),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: AnimatedScale(
                  scale: _showFab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: FloatingActionButton.extended(
                    backgroundColor: Colors.deepPurple,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BlocoSelectionPage(idParty: widget.idParty),
                        ),
                      );
                      _fetchPartyEvents();
                    },
                    label: const Text(
                      "Novo Bloco",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListSliver() {
    final selected = _selectedDay ?? _focusedDay;
    final events = _events[_dayKey(selected)] ?? [];

    if (events.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text("Nenhum bloco agendado")),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final event = events[index];
        final Color themeColor =
            _carnivalColors[index % _carnivalColors.length];
        return KeyedSubtree(
          key: ValueKey(event.id),
          child: _buildEventCard(
            event: event,
            themeColor: themeColor,
            onTap: () => _openEventDetails(event, themeColor),
          ),
        );
      }, childCount: events.length),
    );
  }

  Widget _buildEventCard({
    required PartyEvent event,
    required Color themeColor,
    VoidCallback? onTap,
    bool canVote = true,
  }) {
    final startStr = DateFormat("HH:mm").format(event.start);
    final location = event.location.isEmpty
        ? "Local não informado"
        : event.location;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: themeColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: themeColor.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                event.icon,
                                color: themeColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            _voteBtn(
                              event,
                              'like',
                              "❤️",
                              event.likes,
                              themeColor,
                              onTap: canVote
                                  ? () => _vote(event, 'like')
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            _voteBtn(
                              event,
                              'dislike',
                              "👎",
                              event.dislikes,
                              Colors.orange,
                              onTap: canVote
                                  ? () => _vote(event, 'dislike')
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _buildInfoSquare(
                                  label: "Horário",
                                  color: themeColor,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Início: $startStr",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildInfoSquare(
                                  label: "Lugar",
                                  color: Colors.deepPurple,
                                  child: Center(
                                    child: Text(
                                      location,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _voteBtn(
    PartyEvent event,
    String tipo,
    String emoji,
    int count,
    Color activeColor, {
    VoidCallback? onTap,
  }) {
    final bool isSel = event.myVote == tipo;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedScale(
            scale: isSel ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Opacity(
              opacity: (event.myVote != null && !isSel) ? 0.3 : 1.0,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          Text(
            "$count",
            style: TextStyle(
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
              color: isSel ? activeColor : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSquare({
    required String label,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildVotersSection({
    required String title,
    required List<MemberInfo> users,
    required String emptyText,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          if (users.isEmpty)
            Text(
              emptyText,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            )
          else
            ...users.map(_buildVoterTile),
        ],
      ),
    );
  }

  Widget _buildVoterTile(MemberInfo user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _buildMemberAvatar(user),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(MemberInfo user) {
    final hasAvatar =
        user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;
    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFE2E8F0),
      backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
      child: hasAvatar
          ? null
          : Text(
              _initialFromName(user.name),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
    );
  }

  String _initialFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  Widget _buildHandle() => GestureDetector(
    onTap: () => _controller.animateTo(
      _controller.size > 0.28 ? 0.08 : 0.92,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 45,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
  );
}
