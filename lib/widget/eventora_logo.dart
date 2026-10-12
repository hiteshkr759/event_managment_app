import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable brand logo widget for the **Eventora** application.
///
/// **Purpose:**
/// Renders the official Eventora emblem (a custom-painted gradient ticket &
/// star-sparkle mark inside a rounded squircle) alongside the optional
/// **"Eventora"** wordmark and tagline.
///
/// **How it works:**
/// 1. Uses a [CustomPaint] with [_EventoraEmblemPainter] to draw a crisp,
///    scalable vector ticket silhouette and 4-point event star at any [size].
/// 2. Can be rendered as a compact icon+title row in an [AppBar] (`size: 30`)
///    or as a large vertical hero badge on the splash/loading screen (`size: 84`).
class EventoraLogo extends StatelessWidget {
  /// Width and height of the square logo emblem in logical pixels.
  final double size;

  /// Whether to render the "Eventora" brand name next to or below the emblem.
  final bool showText;

  /// Whether to stack the wordmark vertically below the emblem (for splash screens).
  final bool vertical;

  /// Whether to display the subtitle tagline below the wordmark.
  final bool showTagline;

  /// Whether to use white text for dark or gradient backgrounds.
  final bool lightText;

  /// Creates an [EventoraLogo] widget.
  const EventoraLogo({
    super.key,
    this.size = 36,
    this.showText = true,
    this.vertical = false,
    this.showTagline = false,
    this.lightText = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primaryTextColor = lightText ? Colors.white : scheme.onSurface;
    final secondaryTextColor = lightText
        ? Colors.white70
        : scheme.onSurfaceVariant;

    final emblem = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF004D40),
            Color(0xFF00796B),
            Color(0xFF26A69A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00796B).withValues(alpha: 0.32),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _EventoraEmblemPainter(),
      ),
    );

    if (!showText) return emblem;

    final wordmark = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: vertical ? size * 0.38 : size * 0.62,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: primaryTextColor,
            ),
            children: [
              const TextSpan(text: 'Event'),
              TextSpan(
                text: 'ora',
                style: TextStyle(
                  color: lightText
                      ? const Color(0xFF80CBC4)
                      : const Color(0xFF00897B),
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'DISCOVER • CONNECT • EXPERIENCE',
            style: TextStyle(
              fontSize: vertical ? 11 : 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
              color: secondaryTextColor,
            ),
          ),
        ],
      ],
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          emblem,
          SizedBox(height: size * 0.22),
          wordmark,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        emblem,
        SizedBox(width: size * 0.28),
        wordmark,
      ],
    );
  }
}

// Custom vector painter that draws an event ticket silhouette with side notches
// and a 4-point sparkle star in the center of the Eventora emblem.
class _EventoraEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle inner glow ring
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8),
        Radius.circular(w * 0.2),
      ),
      ringPaint,
    );

    // Draw tilted event ticket outline in the center
    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(-math.pi / 14);

    final ticketW = w * 0.54;
    final ticketH = h * 0.36;
    final halfW = ticketW / 2;
    final halfH = ticketH / 2;
    final notchR = h * 0.065;

    final ticketPath = Path()
      ..moveTo(-halfW + notchR, -halfH)
      ..lineTo(halfW - notchR, -halfH)
      ..quadraticBezierTo(halfW, -halfH, halfW, -halfH + notchR)
      ..lineTo(halfW, -notchR)
      ..arcToPoint(
        Offset(halfW, notchR),
        radius: Radius.circular(notchR),
        clockwise: false,
      )
      ..lineTo(halfW, halfH - notchR)
      ..quadraticBezierTo(halfW, halfH, halfW - notchR, halfH)
      ..lineTo(-halfW + notchR, halfH)
      ..quadraticBezierTo(-halfW, halfH, -halfW, halfH - notchR)
      ..lineTo(-halfW, notchR)
      ..arcToPoint(
        Offset(-halfW, -notchR),
        radius: Radius.circular(notchR),
        clockwise: false,
      )
      ..lineTo(-halfW, -halfH + notchR)
      ..quadraticBezierTo(-halfW, -halfH, -halfW + notchR, -halfH)
      ..close();

    final ticketFill = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    canvas.drawPath(ticketPath, ticketFill);

    // Draw 4-point star spark inside the ticket in brand teal
    final starR = h * 0.11;
    final innerR = starR * 0.36;
    final starPath = Path();
    for (var i = 0; i < 8; i++) {
      final r = i.isEven ? starR : innerR;
      final angle = (i * math.pi / 4) - (math.pi / 2);
      final x = math.cos(angle) * r;
      final y = math.sin(angle) * r;
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    final starPaint = Paint()
      ..color = const Color(0xFF00695C)
      ..style = PaintingStyle.fill;
    canvas.drawPath(starPath, starPaint);
    canvas.restore();

    // Accent sparkle dot in top-right corner
    final dotPaint = Paint()
      ..color = const Color(0xFFA7FFEB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.76, h * 0.24), w * 0.045, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Branded full-screen or section loading screen for **Eventora**.
///
/// **Purpose:**
/// Displays an engaging, polished loading state with the [EventoraLogo], a
/// smooth entrance scale/fade animation, a styled progress indicator, and a
/// contextual message while data is being fetched from Supabase.
///
/// **How it works:**
/// Uses Flutter's [TweenAnimationBuilder] inside a [StatelessWidget] to animate
/// the logo's opacity and scale from `0.88` to `1.0` without needing a
/// `StatefulWidget` or manual `AnimationController`.
class EventoraLoadingScreen extends StatelessWidget {
  /// Primary status headline shown below the logo.
  final String message;

  /// Optional secondary hint text shown below [message].
  final String subtitle;

  /// Whether to wrap the content in a full-screen [Scaffold] (used for app boot)
  /// or render it inline inside an existing screen.
  final bool fullScreen;

  /// Creates an [EventoraLoadingScreen].
  const EventoraLoadingScreen({
    super.key,
    this.message = 'Loading Upcoming Experiences...',
    this.subtitle = 'Syncing live events from Eventora Cloud',
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.88, end: 1.0),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            final opacity = ((scale - 0.88) / 0.12).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Outer ambient glow halo around the Eventora logo
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      scheme.primary.withValues(alpha: 0.14),
                      scheme.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: const EventoraLogo(
                  size: 84,
                  vertical: true,
                  showTagline: true,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!fullScreen) return content;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(child: content),
    );
  }
}

