import 'dart:async';

import '../../data/location_repo.dart';
import '../../data/map_models.dart';

class LocationsPoller {
  LocationsPoller({
    required LocationRepo locationRepo,
    required this.getUserIds,
    required this.onLocations,
    this.interval = const Duration(seconds: 10),
  }) : _locationRepo = locationRepo;

  final LocationRepo _locationRepo;
  final List<String> Function() getUserIds;
  final void Function(List<MemberLocation> locations) onLocations;
  final Duration interval;

  Timer? _timer;
  bool _isPolling = false;

  Future<void> start() async {
    await _pollOnce();
    _timer ??= Timer.periodic(interval, (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (_isPolling) return;

    final userIds = getUserIds();
    if (userIds.isEmpty) return;

    _isPolling = true;
    try {
      final locations = await _locationRepo.fetchLocationsForUsers(userIds);
      onLocations(locations);
    } catch (_) {
      // Mantém último estado em memória quando o backend falhar.
    } finally {
      _isPolling = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
