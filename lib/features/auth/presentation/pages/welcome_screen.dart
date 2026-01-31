import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const _particleCount = 70;
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _particles = _ConfettiParticle.generate(_particleCount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _WelcomeBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    size: constraints.biggest,
                    painter: _ConfettiPainter(
                      progress: _controller.value,
                      particles: _particles,
                    ),
                  );
                },
              );
            },
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'web/icons/logo_512.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        semanticLabel: 'Logo do app',
                      ),
                      const SizedBox(height: 28),
                      _GradientButton(
                        label: 'Entrar',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.register,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TermsText(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.terms,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5E6),
            Color(0xFFF6F0FF),
            AppColors.surface,
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFFC05E),
              Color(0xFF7C4DFF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Ao clicar em Entrar, você concorda com os ',
        style: const TextStyle(
          fontSize: 12,
          height: 1.4,
          color: AppColors.muted,
        ),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InkWell(
              onTap: onTap,
              child: const Text(
                'Termos de Uso',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.color,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
  final double rotation;
  final Color color;

  static List<_ConfettiParticle> generate(int count) {
    final random = Random(42);
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFFC05E),
      const Color(0xFF6EE7B7),
      const Color(0xFF7C4DFF),
      const Color(0xFF38BDF8),
      const Color(0xFFFB7185),
    ];
    return List.generate(
      count,
      (index) => _ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 6 + random.nextDouble() * 8,
        speed: 0.25 + random.nextDouble() * 0.8,
        rotation: random.nextDouble() * pi,
        color: colors[random.nextInt(colors.length)],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.particles});

  final double progress;
  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final time = progress * 2 * pi;
    for (final particle in particles) {
      final dy = (particle.y + progress * particle.speed) % 1.0;
      final dx =
          particle.x + (sin(time + particle.rotation) * 0.02 * particle.speed);
      final offset = Offset(dx * size.width, dy * size.height);
      final paint = Paint()..color = particle.color.withOpacity(0.9);
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(particle.rotation + time * 0.2);
      final rect =
          Rect.fromCenter(center: Offset.zero, width: particle.size, height: 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
