class PartyMemberItem {
  const PartyMemberItem({
    required this.userId,
    required this.displayLabel,
    required this.role,
    required this.status,
    required this.isMe,
    this.displayName,
    this.avatarUrl,
  });

  final String userId;
  final String displayLabel;
  final String role;
  final String status;
  final bool isMe;
  final String? displayName;
  final String? avatarUrl;

  PartyMemberItem copyWith({
    String? role,
    String? status,
    String? displayLabel,
    String? displayName,
    String? avatarUrl,
  }) {
    return PartyMemberItem(
      userId: userId,
      displayLabel: displayLabel ?? this.displayLabel,
      role: role ?? this.role,
      status: status ?? this.status,
      isMe: isMe,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
