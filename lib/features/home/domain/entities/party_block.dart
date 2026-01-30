class PartyBlock {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String status;
  final int occupancyPercent;

  const PartyBlock({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.status,
    required this.occupancyPercent,
  });
}
