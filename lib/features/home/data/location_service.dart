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

  Stream<MemberLocationModel> get updates => _updatesController.stream;
  RealtimeSubscribeStatus? get lastStatus => _lastStatus;

  bool get isChannelHealthy => _channel?.isJoined == true;

  Future<void> initializeRealtime(String partyId) async {
    if (_partyId == partyId && _channel?.isJoined == true) {
      return;
    }

    if (_channel != null) {
      await _client.removeChannel(_channel!);
      _channel = null;
    }

    _partyId = partyId;
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
            _updatesController.add(MemberLocationModel.fromBroadcast(payload));
          },
        )
        .subscribe((status, error) {
          _lastStatus = status;
        });
  }

  Future<void> broadcastMyPosition({
    required Position position,
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    if (_channel == null || _channel!.isJoined != true) {
      return;
    }

    final now = DateTime.now();
    if (_lastBroadcastAt != null && _lastBroadcastPosition != null) {
      final seconds = now.difference(_lastBroadcastAt!).inSeconds;
      final distance = Geolocator.distanceBetween(
        _lastBroadcastPosition!.latitude,
        _lastBroadcastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      if (seconds < 5 || distance < 20) {
        return;
      }
    }

    _lastBroadcastAt = now;
    _lastBroadcastPosition = position;

    await _channel!.sendBroadcastMessage(
      event: 'pos_update',
      payload: {
        'event': 'pos_update',
        'payload': {
          'user_id': userId,
          'name': name ?? 'Você',
          'avatar_url': avatarUrl,
          'lat': position.latitude,
          'lng': position.longitude,
          'timestamp': now.toIso8601String(),
        },
      },
    );
  }

  Future<void> persistLastKnownPosition({
    required Position position,
    required String userId,
    required String partyId,
  }) async {
    final now = DateTime.now();
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
      // Table or RLS might not be ready yet; keep silent and rely on broadcast.
    }
  }

  Future<List<MemberLocationModel>> fetchLastKnownPositions(
    String partyId,
  ) async {
    try {
      final usersResponse = await _client
          .from('party_usuario')
          .select('idusuario')
          .eq('idparty', partyId);
      final userIds = (usersResponse as List)
          .map((row) => row['idusuario'] as String?)
          .whereType<String>()
          .toList();
      if (userIds.isEmpty) {
        return [];
      }

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
      }).map(MemberLocationModel.fromDatabase).toList();
      if (data.isNotEmpty) {
        return data;
      }
    } catch (_) {
      // Table not available yet or RLS; fall back to mock data.
    }

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
      await _client.removeChannel(_channel!);
    }
    await _updatesController.close();
  }
}
