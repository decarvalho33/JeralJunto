import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../party/presentation/pages/party_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../profile/presentation/pages/settings_screen.dart';
import '../../data/map_models.dart';
import '../providers/map_providers.dart';
import '../services/location_sender.dart';
import '../services/locations_poller.dart';
import '../widgets/header_overlay.dart';
import '../widgets/no_party_overlay.dart';
import '../widgets/party_map_view.dart';
import '../widgets/schedule_sheet_placeholder.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _supabase = Supabase.instance.client;
  final _mapController = MapController();
  final Set<String> _prefetchedAvatarUrls = <String>{};

  List<Map<String, dynamic>> _userParties = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  List<String> _memberIdsForPolling = const [];
  int? _activePartyId;
  LocationSender? _locationSender;
  LocationsPoller? _locationsPoller;

  @override
  void initState() {
    super.initState();
    _startLocationSender();
    _loadParties();
  }

  Future<void> _startLocationSender() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _locationSender?.dispose();
    _locationSender = LocationSender(
      locationRepo: ref.read(locationRepoProvider),
      userId: user.id,
      onPermissionChanged: (state) {
        if (!mounted) return;
        ref.read(locationPermissionStateProvider.notifier).state = state;
      },
      onForegroundPosition: (Position position) {
        if (!mounted) return;
        ref.read(myLocationProvider.notifier).state = LatLng(
          position.latitude,
          position.longitude,
        );
      },
    );

    await _locationSender!.start();
  }

  Future<void> _requestLocationPermission() async {
    await _locationSender?.requestPermission();
  }

  Future<void> _loadParties() async {
    try {
      final user = _supabase.auth.currentUser;
      final data = await _supabase
          .from('Party_Usuario')
          .select('Party ( id, nome )')
          .eq('idUsuario', user?.id ?? '');

      if (!mounted) return;
      final parties = (data as List)
          .map((item) => item['Party'] as Map<String, dynamic>)
          .toList(growable: false);

      setState(() {
        _userParties = parties;
        if (_currentIndex >= parties.length) {
          _currentIndex = 0;
        }
        _isLoading = false;
      });

      await _activateCurrentParty();
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _activateCurrentParty() async {
    if (_userParties.isEmpty) return;

    final partyId = (_userParties[_currentIndex]['id'] as num?)?.toInt() ?? 0;
    if (partyId <= 0) return;

    ref.read(currentPartyIdProvider.notifier).state = partyId;
    ref.read(selectedMemberIdProvider.notifier).state = null;

    if (_activePartyId == partyId) return;

    if (_activePartyId != null) {
      ref.read(memberLocationsProvider(_activePartyId!).notifier).reset();
    }

    _activePartyId = partyId;
    _memberIdsForPolling = const [];

    _locationsPoller?.dispose();
    _locationsPoller = LocationsPoller(
      locationRepo: ref.read(locationRepoProvider),
      getUserIds: () => _memberIdsForPolling,
      onLocations: (locations) {
        if (!mounted || _activePartyId != partyId) return;
        ref
            .read(memberLocationsProvider(partyId).notifier)
            .mergeFromPoll(locations);
      },
    );

    await _locationsPoller!.start();
  }

  void _syncMembersForPolling(int partyId, List<MemberInfo> members) {
    if (_activePartyId != partyId) return;

    final ids = members.map((member) => member.id).toList(growable: false);
    if (!listEquals(ids, _memberIdsForPolling)) {
      _memberIdsForPolling = ids;
    }

    for (final member in members) {
      final avatarUrl = member.avatarUrl;
      if (avatarUrl == null ||
          avatarUrl.isEmpty ||
          _prefetchedAvatarUrls.contains(avatarUrl)) {
        continue;
      }
      _prefetchedAvatarUrls.add(avatarUrl);
      precacheImage(NetworkImage(avatarUrl), context);
    }
  }

  void _openProfileMenu(BuildContext context) {
    final rootContext = context;
    showModalBottomSheet<void>(
      context: rootContext,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Meu perfil'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(rootContext).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Configurações'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(rootContext).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Termos de Serviço'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(rootContext).pushNamed(AppRoutes.terms);
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Política de Privacidade'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(rootContext).pushNamed(AppRoutes.privacy);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await AuthRepository().signOut();
                  if (rootContext.mounted) {
                    Navigator.of(
                      rootContext,
                    ).pushNamedAndRemoveUntil(AppRoutes.root, (_) => false);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _dialPolice() async {
    final uri = Uri(scheme: 'tel', path: '190');
    await launchUrl(uri);
  }

  void _openPanicDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alerta de pânico',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ao confirmar, você vai avisar TODO o grupo imediatamente.',
                  style: TextStyle(fontSize: 15, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      // TODO: integrar fluxo real de pânico.
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alerta enviado para o grupo.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    child: const Text('AVISAR O GRUPO'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call, color: Colors.red),
                    label: const Text(
                      'Discar 190',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                    ),
                    onPressed: _dialPolice,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _locationSender?.dispose();
    _locationsPoller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_userParties.isEmpty) {
      return NoPartyOverlay(onRefresh: _loadParties);
    }

    final currentParty = _userParties[_currentIndex];
    final currentPartyId = (currentParty['id'] as num?)?.toInt() ?? 0;

    final membersAsync = ref.watch(partyMembersProvider(currentPartyId));
    membersAsync.whenData(
      (members) => _syncMembersForPolling(currentPartyId, members),
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PartyMapView(
            partyId: currentPartyId,
            mapController: _mapController,
            onRequestLocationPermission: _requestLocationPermission,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ScheduleSheetPlaceholder(idParty: currentPartyId),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: HeaderOverlay(
              partyName: currentParty['nome']?.toString() ?? 'Party',
              onPanicTap: () => _openPanicDialog(context),
              onPartyTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PartyScreen()),
                );
                await _loadParties();
              },
              onAvatarTap: () => _openProfileMenu(context),
            ),
          ),
        ],
      ),
    );
  }
}
