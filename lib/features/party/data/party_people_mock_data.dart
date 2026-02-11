import 'package:flutter/material.dart';

import '../domain/models/party_member_battery.dart';

class PartyPeopleData {
  const PartyPeopleData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.currentUserName,
    required this.members,
  });

  final String id;
  final String name;
  final String subtitle;
  final String currentUserName;
  final List<PartyMemberBattery> members;
}

const PartyPeopleData partyPeopleMockData = PartyPeopleData(
  id: 'party_01',
  name: 'Bloco das Estrelas',
  subtitle: 'Carnaval 2025 - Centro historico',
  currentUserName: 'Duda',
  members: [
    PartyMemberBattery(
      name: 'Duda',
      role: 'Admin',
      batteryLevel: 82,
      lastUpdate: 'agora',
      isCharging: false,
      isOnline: true,
      accentColor: Color(0xFFEDE9FE),
    ),
    PartyMemberBattery(
      name: 'Caio',
      role: 'Ritmo',
      batteryLevel: 56,
      lastUpdate: '1 min',
      isCharging: true,
      isOnline: true,
      accentColor: Color(0xFFDCFCE7),
    ),
    PartyMemberBattery(
      name: 'Lia',
      role: 'Nucleo',
      batteryLevel: 28,
      lastUpdate: '3 min',
      isCharging: false,
      isOnline: true,
      accentColor: Color(0xFFFFEDD5),
    ),
    PartyMemberBattery(
      name: 'Rafa',
      role: 'Convidado',
      batteryLevel: 91,
      lastUpdate: 'agora',
      isCharging: false,
      isOnline: true,
      accentColor: Color(0xFFDBEAFE),
    ),
    PartyMemberBattery(
      name: 'Maya',
      role: 'Convidada',
      batteryLevel: 14,
      lastUpdate: '5 min',
      isCharging: false,
      isOnline: false,
      accentColor: Color(0xFFFCE7F3),
    ),
  ],
);
