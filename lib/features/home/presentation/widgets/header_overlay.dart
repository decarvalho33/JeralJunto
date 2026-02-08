import 'package:flutter/material.dart';

import '../../../../core/widgets/user_avatar.dart';

class HeaderOverlay extends StatelessWidget {
  const HeaderOverlay({
    super.key,
    required this.partyName,
    required this.onPanicTap,
    required this.onPartyTap,
    required this.onAvatarTap,
  });

  final String partyName;
  final VoidCallback onPanicTap;
  final VoidCallback onPartyTap;
  final VoidCallback onAvatarTap;

  double _fitPartyFontSize(
    BuildContext context, {
    required String text,
    required double maxWidth,
  }) {
    const maxFontSize = 19.0;
    const minFontSize = 13.0;

    if (maxWidth.isInfinite || maxWidth <= 0) return maxFontSize;

    final textDirection = Directionality.of(context);
    final painter = TextPainter(textDirection: textDirection, maxLines: 1);

    double current = maxFontSize;
    while (current >= minFontSize) {
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: current,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
        ),
      );
      painter.layout(maxWidth: maxWidth);
      if (!painter.didExceedMaxLines && painter.width <= maxWidth) {
        return current;
      }
      current -= 0.5;
    }

    return minFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // botão de panico
            SizedBox(
              width: 52,
              height: 52,
              child: FloatingActionButton(
                heroTag: 'panic',
                backgroundColor: Colors.red.shade600,
                onPressed: onPanicTap,
                child: const Icon(Icons.emergency_share, size: 24),
              ),
            ),

            // seletor de gp dinamico
            Flexible(
              fit: FlexFit.loose,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: onPartyTap,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFF3F5F8)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFDCE2EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final fontSize = _fitPartyFontSize(
                                      context,
                                      text: partyName,
                                      maxWidth: constraints.maxWidth,
                                    );
                                    return Text(
                                      partyName,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '|',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.qr_code_2_rounded,
                                size: 21,
                                color: Color(0xFF374151),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // avatar do perfil
            InkResponse(
              onTap: onAvatarTap,
              radius: 30,
              child: const UserAvatar(
                radius: 27,
                backgroundColor: Color(0xFFCBD5E1),
                iconColor: Colors.white,
                iconSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
