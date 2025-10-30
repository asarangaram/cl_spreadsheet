import 'package:flutter/material.dart';

class CreditCardWindow extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final double bannerHeight;
  final String title;

  const CreditCardWindow({
    super.key,
    this.width = 340,
    this.height = 200,
    this.borderRadius = 18,
    this.bannerHeight = 40,
    this.title = 'My Desktop Window',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          // Material used to get proper shadow clipping with border radius
          elevation: 8,
          borderRadius: BorderRadius.circular(borderRadius),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                // Background gradient + curved texture (painted)
                Positioned.fill(
                  child: CustomPaint(painter: _CardTexturePainter()),
                ),

                // Top banner that looks like a desktop window title bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: bannerHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          topRight: Radius.circular(borderRadius),
                        ),
                      ),
                      child: Row(
                        children: [
                          // "Window controls" left
                          Row(
                            children: [
                              WindowDot(color: Colors.redAccent),
                              const SizedBox(width: 6),
                              WindowDot(color: Colors.orangeAccent),
                              const SizedBox(width: 6),
                              WindowDot(color: Colors.greenAccent),
                            ],
                          ),

                          // Title centered (flexible)
                          Expanded(
                            child: Center(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // Optional action icon on right
                          Icon(
                            Icons.more_vert,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ),

                    // Remaining card content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CardContent(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WindowDot extends StatelessWidget {
  final Color color;
  const WindowDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(child: Icon(Icons.close)),
    );
  }
}

class CardContent extends StatelessWidget {
  const CardContent({super.key});

  // Example content: card chip, number, name. Replace with your own widgets.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // chip stub
        Container(
          width: 52,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const Spacer(),
        Text(
          '**** **** **** 3456',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 20,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ANANDA S.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '12/29',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter draws gradient background plus subtle curved waves texture.
class _CardTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F172A), Color(0xFF0B3A6F)],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);

    // Soft highlight (diagonal)
    final Path highlight = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width * 0.6, size.height * 0.45),
          Radius.circular(24),
        ),
      );

    final Paint highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width * 0.6, size.height * 0.45));

    canvas.drawPath(highlight, highlightPaint);

    // Curved texture lines (subtle waves)
    final Paint wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.03), Colors.transparent],
      ).createShader(rect);

    final double waveCount = 3;
    for (int i = 0; i < waveCount; i++) {
      final double offsetY = size.height * (0.25 + i * 0.12);
      final Path p = Path();
      p.moveTo(-30, offsetY);
      p.quadraticBezierTo(
        size.width * 0.25,
        offsetY - 18 - i * 6,
        size.width * 0.5,
        offsetY,
      );
      p.quadraticBezierTo(
        size.width * 0.75,
        offsetY + 18 + i * 6,
        size.width + 30,
        offsetY,
      );
      canvas.drawPath(p, wavePaint);
    }

    // Very subtle noise by drawing faint strokes (optional)
    final Paint stripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 0.6;
    for (double y = 0; y < size.height; y += 14) {
      final double startX = -10;
      final double endX = size.width + 10;
      canvas.drawLine(Offset(startX, y + 2), Offset(endX, y + 2), stripe);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
