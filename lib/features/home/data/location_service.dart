import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'member_location_model.dart';

class LocationService {
  LocationService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  final StreamController<MemberLocationModel> _updatesController =
      StreamController<MemberLocationModel>.broadcast();

  RealtimeChannel? _channel;
  String? _partyId;

  DateTime? _lastBroadcastAt;
  Position? _lastBroadcastPosition;

  DateTime? _lastPersistedAt;

  RealtimeSubscribeStatus? _lastStatus;
  bool _isSubscribed = false;

  Stream<MemberLocationModel> get updates => _updatesController.stream;
  RealtimeSubscribeStatus? get lastStatus => _lastStatus;

  /// ✅ Saúde do canal baseada em API pública:
  /// - subscribed => saudável
  bool get isChannelHealthy =>
      _channel != null && _isSubscribed && _lastStatus == RealtimeSubscribeStatus.subscribed;

  Future<void> initializeRealtime(String partyId) async {
    // Se já estamos no mesmo party e já subscribed, não faz nada.
    if (_partyId == partyId && _channel != null && _isSubscribed) {
      return;
    }

    // Se tinha outro canal, remove.
    if (_channel != null) {
      try {
        await _client.removeChannel(_channel!);
      } catch (_) {
        // ignore: best-effort cleanup
      }
      _channel = null;
    }

    _partyId = partyId;
    _isSubscribed = false;

    _channel = _client.channel(
      'room:$partyId',
      opts: const RealtimeChannelConfig(
        ack: false,
        self: false,
      ),
    );

    _channel!
        .onBroadcast(
          event: 'pos_update',
          callback: (payload) {
            try {
              _updatesController.add(MemberLocationModel.fromBroadcast(payload));
            } catch (_) {
              // evita crash se payload vier inesperado
            }
          },
        )
        .subscribe((status, error) {
          _lastStatus = status;

          // ✅ controle do estado "pronto"
          if (status == RealtimeSubscribeStatus.subscribed) {
            _isSubscribed = true;
          } else if (status == RealtimeSubscribeStatus.closed ||
              status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            _isSubscribed = false;
          }

          // (opcional) você pode logar error se quiser
          // if (error != null) debugPrint('Realtime error: $error');
        });
  }

  Future<void> broadcastMyPosition({
    required Position position,
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    // ✅ sem isJoined (interno). Usamos estado público:
    if (_channel == null || !_isSubscribed) return;

    final now = DateTime.now();

    // Throttle por tempo + distância (mantive seu comportamento)
    if (_lastBroadcastAt != null && _lastBroadcastPosition != null) {
      final seconds = now.difference(_lastBroadcastAt!).inSeconds;
      final distance = Geolocator.distanceBetween(
        _lastBroadcastPosition!.latitude,
        _lastBroadcastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Seu código original: "seconds < 5 OU distance < 20" => segura bastante.
      // Mantive igual.
      if (seconds < 5 || distance < 20) return;
    }

    _lastBroadcastAt = now;
    _lastBroadcastPosition = position;

    // ✅ payload simples e consistente
    final payload = <String, dynamic>{
      'user_id': userId,
      'name': name ?? 'Você',
      'avatar_url': avatarUrl,
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': now.toIso8601String(),
      'party_id': _partyId, // útil pra debug (opcional)
    };

    try {
      await _channel!.sendBroadcastMessage(
        event: 'pos_update',
        payload: payload,
      );
    } catch (_) {
      // Se falhar, não derruba o app (MVP)
    }
  }

  Future<void> persistLastKnownPosition({
    required Position position,
    required String userId,
    required String partyId,
  }) async {
    final now = DateTime.now();

    // Rate limit de persistência (mantive)
    if (_lastPersistedAt != null &&
        now.difference(_lastPersistedAt!).inSeconds < 60) {
      return;
    }
    _lastPersistedAt = now;

    try {
      await _client.from('localizacao').upsert({
        'idusuario': userId,
        'ultimaatt': now.toIso8601String(),
        'posicao': 'POINT(${position.longitude} ${position.latitude})',
      });
    } catch (_) {
      // Table/RLS podem não estar prontos; silencioso pro MVP.
    }
  }

  Future<List<MemberLocationModel>> fetchLastKnownPositions(String partyId) async {
    try {
      final usersResponse = await _client
          .from('party_usuario')
          .select('idusuario')
          .eq('idparty', partyId);

      final userIds = (usersResponse as List)
          .map((row) => row['idusuario'] as String?)
          .whereType<String>()
          .toList();

      if (userIds.isEmpty) return [];

      final response = await _client
          .from('localizacao')
          .select('idusuario, ultimaatt, posicao, usuario(nome)')
          .inFilter('idusuario', userIds);

      final data = (response as List)
          .cast<Map<String, dynamic>>()
          .map((row) {
            final usuario = row['usuario'] as Map<String, dynamic>?;
            return {
              ...row,
              if (usuario != null) 'nome': usuario['nome'],
            };
          })
          .map(MemberLocationModel.fromDatabase)
          .toList();

      if (data.isNotEmpty) return data;
    } catch (_) {
      // fallthrough to mock
    }

    // fallback mock (mantive)
    return <MemberLocationModel>[
      MemberLocationModel(
        userId: 'mock-1',
        name: 'Bia',
        lat: -22.9068,
        lng: -43.1737,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      MemberLocationModel(
        userId: 'mock-2',
        name: 'Dani',
        lat: -22.9083,
        lng: -43.1712,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  Future<void> dispose() async {
    if (_channel != null) {
      try {
        await _client.removeChannel(_channel!);
      } catch (_) {
        // ignore
      }
      _channel = null;
    }
    await _updatesController.close();
  }
}
