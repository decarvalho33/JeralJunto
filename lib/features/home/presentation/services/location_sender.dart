import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../data/location_repo.dart';
import '../../data/map_models.dart';

class LocationSender {
  LocationSender({
    required LocationRepo locationRepo,
    required this.userId,
    this.interval = const Duration(seconds: 7),
    this.minDistanceMeters = 10,
    this.onPermissionChanged,
    this.onForegroundPosition,
  }) : _locationRepo = locationRepo;

  final LocationRepo _locationRepo;
  final String userId;
  final Duration interval;
  final double minDistanceMeters;
  final void Function(LocationPermissionUiState state)? onPermissionChanged;
  final void Function(Position position)? onForegroundPosition;

  Timer? _timer;
  bool _isTicking = false;
  Position? _lastSentPosition;

  Future<void> start({bool requestPermissionIfNeeded = true}) async {
    await _tick(requestPermissionIfNeeded: requestPermissionIfNeeded);
    _timer ??= Timer.periodic(interval, (_) => _tick());
  }

  Future<void> requestPermission() async {
    await _tick(requestPermissionIfNeeded: true);
  }

  Future<void> _tick({bool requestPermissionIfNeeded = false}) async {
    if (_isTicking) return;
    _isTicking = true;

    try {
      final hasPermission = await _ensurePermission(
        requestIfNeeded: requestPermissionIfNeeded,
      );
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      onForegroundPosition?.call(position);

      if (!_shouldSend(position)) return;

      // TODO: integrar bateria real quando houver estratégia multiplataforma.
      await _locationRepo.setMyLocation(
        userId: userId,
        lat: position.latitude,
        lng: position.longitude,
        batteryHealth: 100,
      );
      _lastSentPosition = position;
    } catch (_) {
      // Mantém silencioso para não quebrar UX no beta web.
    } finally {
      _isTicking = false;
    }
  }

  bool _shouldSend(Position currentPosition) {
    if (_lastSentPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastSentPosition!.latitude,
      _lastSentPosition!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distance >= minDistanceMeters;
  }

  Future<bool> _ensurePermission({required bool requestIfNeeded}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onPermissionChanged?.call(LocationPermissionUiState.serviceDisabled);
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestIfNeeded) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      onPermissionChanged?.call(LocationPermissionUiState.denied);
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      onPermissionChanged?.call(LocationPermissionUiState.deniedForever);
      return false;
    }

    onPermissionChanged?.call(LocationPermissionUiState.granted);
    return true;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
