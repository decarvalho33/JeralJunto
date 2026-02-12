import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../data/location_repo.dart';
import '../../data/map_models.dart';

class LocationSender {
  LocationSender({
    required LocationRepo locationRepo,
    required this.userId,
    this.minDistanceMeters = 3,
    this.minSendInterval = const Duration(seconds: 2),
    this.onPermissionChanged,
    this.onForegroundPosition,
  }) : _locationRepo = locationRepo;

  final LocationRepo _locationRepo;
  final String userId;
  final double minDistanceMeters;
  final Duration minSendInterval;
  final void Function(LocationPermissionUiState state)? onPermissionChanged;
  final void Function(Position position)? onForegroundPosition;

  static const LocationSettings _streamSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 1,
  );

  StreamSubscription<Position>? _positionSubscription;
  bool _isSending = false;
  Position? _lastSentPosition;
  DateTime? _lastSentAt;

  Future<void> start({bool requestPermissionIfNeeded = true}) async {
    final hasPermission = await _ensurePermission(
      requestIfNeeded: requestPermissionIfNeeded,
    );
    if (!hasPermission) return;

    await _startStreamingIfNeeded();
    await _fetchAndProcessSinglePosition();
  }

  Future<void> requestPermission() async {
    final hasPermission = await _ensurePermission(requestIfNeeded: true);
    if (!hasPermission) return;

    await _startStreamingIfNeeded();
    await _fetchAndProcessSinglePosition();
  }

  Future<void> _startStreamingIfNeeded() async {
    if (_positionSubscription != null) return;

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: _streamSettings).listen(
          (position) {
            unawaited(_processPosition(position));
          },
          onError: (Object error) {
            if (error is PermissionDeniedException) {
              onPermissionChanged?.call(LocationPermissionUiState.denied);
            }
          },
          cancelOnError: false,
        );
  }

  Future<void> _fetchAndProcessSinglePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      await _processPosition(position);
    } catch (_) {
      // Mantém silencioso para não quebrar UX no beta web.
    }
  }

  Future<void> _processPosition(Position position) async {
    onForegroundPosition?.call(position);

    if (!_shouldSend(position) || _isSending) return;

    _isSending = true;
    try {
      // TODO: integrar bateria real quando houver estratégia multiplataforma.
      await _locationRepo.setMyLocation(
        userId: userId,
        lat: position.latitude,
        lng: position.longitude,
        batteryHealth: 100,
      );
      _lastSentPosition = position;
      _lastSentAt = DateTime.now();
    } catch (_) {
      // Mantém silencioso para não quebrar UX no beta web.
    } finally {
      _isSending = false;
    }
  }

  bool _hasReachedMinSendInterval() {
    if (_lastSentAt == null) return true;
    return DateTime.now().difference(_lastSentAt!) >= minSendInterval;
  }

  bool _shouldSend(Position currentPosition) {
    if (_lastSentPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastSentPosition!.latitude,
      _lastSentPosition!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distance >= minDistanceMeters || _hasReachedMinSendInterval();
  }

  Future<bool> _ensurePermission({required bool requestIfNeeded}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onPermissionChanged?.call(LocationPermissionUiState.serviceDisabled);
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if ((permission == LocationPermission.denied ||
            permission == LocationPermission.unableToDetermine) &&
        requestIfNeeded) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
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
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
