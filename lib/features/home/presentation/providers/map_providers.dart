import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/location_repo.dart';
import '../../data/map_models.dart';
import '../../data/party_repo.dart';

// TODO: substituir por seleção real de party quando o fluxo definitivo estiver pronto.
final currentPartyIdProvider = StateProvider<int>((ref) => 0);

final selectedMemberIdProvider = StateProvider<String?>((ref) => null);

final myLocationProvider = StateProvider<LatLng?>((ref) => null);

final locationPermissionStateProvider =
    StateProvider<LocationPermissionUiState>(
      (ref) => LocationPermissionUiState.unknown,
    );

final partyRepoProvider = Provider<PartyRepo>((ref) => PartyRepo());

final locationRepoProvider = Provider<LocationRepo>((ref) => LocationRepo());

final partyMembersProvider = FutureProvider.family<List<MemberInfo>, int>((
  ref,
  partyId,
) async {
  final partyRepo = ref.watch(partyRepoProvider);
  final memberIds = await partyRepo.fetchMemberUserIds(partyId);
  return partyRepo.fetchUsersByIds(memberIds);
});

final memberLocationsProvider =
    NotifierProvider.family<
      MemberLocationsNotifier,
      Map<String, MemberLocation>,
      int
    >(MemberLocationsNotifier.new);

class MemberLocationsNotifier
    extends FamilyNotifier<Map<String, MemberLocation>, int> {
  @override
  Map<String, MemberLocation> build(int partyId) => <String, MemberLocation>{};

  void mergeFromPoll(List<MemberLocation> locations) {
    final merged = Map<String, MemberLocation>.from(state);
    for (final location in locations) {
      merged[location.userId] = location;
    }
    state = merged;
  }

  void reset() {
    state = <String, MemberLocation>{};
  }
}
