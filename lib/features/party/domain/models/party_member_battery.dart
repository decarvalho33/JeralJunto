import 'package:flutter/material.dart';

class PartyMemberBattery {
  const PartyMemberBattery({
    required this.name,
    required this.role,
    required this.batteryLevel,
    required this.lastUpdate,
    this.isCharging = false,
    this.isOnline = true,
    this.accentColor,
  });

  final String name;
  final String role;
  final int batteryLevel;
  final String lastUpdate;
  final bool isCharging;
  final bool isOnline;
  final Color? accentColor;
}
