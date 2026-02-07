import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/user_profile_provider.dart';

class UserAvatar extends ConsumerWidget {
  const UserAvatar({
    super.key,
    this.radius = 24,
    this.backgroundColor = const Color(0xFFCBD5E1),
    this.iconColor = Colors.white,
    this.iconSize,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.glowColor = Colors.transparent,
    this.glowBlur = 0,
    this.glowSpread = 0,
    this.borderPadding = EdgeInsets.zero,
  });

  final double radius;
  final Color backgroundColor;
  final Color iconColor;
  final double? iconSize;
  final Color borderColor;
  final double borderWidth;
  final Color glowColor;
  final double glowBlur;
  final double glowSpread;
  final EdgeInsets borderPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final avatarUrl = profile.value?.avatarUrl;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? NetworkImage(avatarUrl)
          : null,
      child: (avatarUrl == null || avatarUrl.isEmpty)
          ? Icon(Icons.person, color: iconColor, size: iconSize ?? radius)
          : null,
    );

    if (borderWidth <= 0 && glowBlur <= 0 && glowSpread <= 0) {
      return avatar;
    }

    return Container(
      padding: borderPadding,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: glowBlur > 0 || glowSpread > 0
            ? [
                BoxShadow(
                  color: glowColor,
                  blurRadius: glowBlur,
                  spreadRadius: glowSpread,
                ),
              ]
            : null,
      ),
      child: avatar,
    );
  }
}
