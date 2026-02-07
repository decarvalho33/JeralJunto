import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/map_models.dart';
import '../providers/map_providers.dart';

class PartyMapView extends ConsumerWidget {
  const PartyMapView({
    super.key,
    required this.partyId,
    required this.mapController,
    required this.onRequestLocationPermission,
  });

  final int partyId;
  final MapController mapController;
  final VoidCallback onRequestLocationPermission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(partyMembersProvider(partyId));
    final members = membersAsync.valueOrNull ?? const <MemberInfo>[];
    final memberLocations = ref.watch(memberLocationsProvider(partyId));
    final selectedMemberId = ref.watch(selectedMemberIdProvider);
    final myLocation = ref.watch(myLocationProvider);
    final permissionState = ref.watch(locationPermissionStateProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    MemberInfo? selectedMember;
    if (selectedMemberId != null) {
      for (final member in members) {
        if (member.id == selectedMemberId) {
          selectedMember = member;
          break;
        }
      }
    }

    final selectedLocation = selectedMember == null
        ? null
        : memberLocations[selectedMember.id];

    final markers = <Marker>[
      if (myLocation != null)
        Marker(
          point: myLocation,
          width: 64,
          height: 64,
          child: const _MyMarker(),
        ),
      for (final member in members)
        if (member.id != currentUserId)
          if (memberLocations[member.id] case final location?)
            Marker(
              point: LatLng(location.lat, location.lng),
              width: selectedMemberId == member.id ? 72 : 60,
              height: selectedMemberId == member.id ? 72 : 60,
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedMemberIdProvider.notifier).state = member.id;
                },
                child: _MemberMarker(
                  member: member,
                  isSelected: selectedMemberId == member.id,
                ),
              ),
            ),
    ];

    final initialCenter =
        myLocation ??
        (memberLocations.values.isNotEmpty
            ? LatLng(
                memberLocations.values.first.lat,
                memberLocations.values.first.lng,
              )
            : const LatLng(-22.9068, -43.1729));

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 15,
            onTap: (_, _) {
              ref.read(selectedMemberIdProvider.notifier).state = null;
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              tileProvider: CancellableNetworkTileProvider(),
              retinaMode: MediaQuery.devicePixelRatioOf(context) > 1.0,
              userAgentPackageName: 'com.example.jeraljunto',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        if (membersAsync.isLoading)
          const Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (permissionState != LocationPermissionUiState.granted)
          Positioned(
            left: 16,
            right: 16,
            top: 110,
            child: _LocationPermissionCard(
              state: permissionState,
              onEnableTap: onRequestLocationPermission,
            ),
          ),
        Positioned(
          left: 12,
          bottom: 150,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '© OpenStreetMap © CARTO',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 190,
          child: FloatingActionButton.small(
            heroTag: 'recenter_me',
            backgroundColor: const Color(0xFF1F2937),
            foregroundColor: Colors.white,
            onPressed: myLocation == null
                ? null
                : () {
                    mapController.move(
                      myLocation,
                      _readCurrentZoom(mapController),
                    );
                  },
            child: const Icon(Icons.my_location),
          ),
        ),
        if (selectedMember != null && selectedLocation != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 180,
            child: _SelectedMemberCard(
              member: selectedMember,
              location: selectedLocation,
              onCenterTap: () {
                mapController.move(
                  LatLng(selectedLocation.lat, selectedLocation.lng),
                  _readCurrentZoom(mapController),
                );
              },
            ),
          ),
      ],
    );
  }
}

double _readCurrentZoom(MapController controller) {
  try {
    return controller.camera.zoom;
  } catch (_) {
    return 15;
  }
}

class _MyMarker extends StatelessWidget {
  const _MyMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x8038BDF8),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberMarker extends StatelessWidget {
  const _MemberMarker({required this.member, required this.isSelected});

  final MemberInfo member;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        member.avatarUrl != null && member.avatarUrl!.trim().isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.transparent,
          width: isSelected ? 3 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.6 : 0.35),
            blurRadius: isSelected ? 12 : 7,
            spreadRadius: isSelected ? 1 : 0,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: isSelected ? 27 : 22,
        backgroundColor: const Color(0xFF1F2937),
        backgroundImage: hasAvatar ? NetworkImage(member.avatarUrl!) : null,
        child: hasAvatar
            ? null
            : const Icon(Icons.person, color: Colors.white70, size: 20),
      ),
    );
  }
}

class _SelectedMemberCard extends StatelessWidget {
  const _SelectedMemberCard({
    required this.member,
    required this.location,
    required this.onCenterTap,
  });

  final MemberInfo member;
  final MemberLocation location;
  final VoidCallback onCenterTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        member.avatarUrl != null && member.avatarUrl!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF1F2937),
              backgroundImage: hasAvatar
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: hasAvatar
                  ? null
                  : const Icon(Icons.person, color: Colors.white70),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Última atualização: ${_formatRelative(location.updatedAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: onCenterTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
              ),
              child: const Text('Centralizar nele'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPermissionCard extends StatelessWidget {
  const _LocationPermissionCard({
    required this.state,
    required this.onEnableTap,
  });

  final LocationPermissionUiState state;
  final VoidCallback onEnableTap;

  @override
  Widget build(BuildContext context) {
    final message = switch (state) {
      LocationPermissionUiState.serviceDisabled =>
        'Ative o serviço de localização do dispositivo.',
      LocationPermissionUiState.deniedForever =>
        'Permissão bloqueada. Libere a localização no navegador.',
      _ => 'Ative localização para mostrar você no mapa.',
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: onEnableTap,
              child: const Text('Ativar localização'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRelative(DateTime updatedAt) {
  final now = DateTime.now();
  final diff = now.difference(updatedAt);
  if (diff.inSeconds < 60) return 'há ${diff.inSeconds}s';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
  if (diff.inHours < 24) return 'há ${diff.inHours}h';
  return 'há ${diff.inDays}d';
}
