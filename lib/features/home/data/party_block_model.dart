class PartyBlockModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String status;
  final int occupancyPercent;

  const PartyBlockModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.status,
    required this.occupancyPercent,
  });

  factory PartyBlockModel.fromJson(Map<String, dynamic> json) {
    return PartyBlockModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
      occupancyPercent: (json['occupancyPercent'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'status': status,
      'occupancyPercent': occupancyPercent,
    };
  }
}
