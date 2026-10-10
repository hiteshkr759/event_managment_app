import 'package:event_managment_app/models/event_model.dart';
import 'package:flutter/material.dart';

/// Displays an event image from the network, or a gradient + icon fallback
/// if the image fails to load.
class EventBannerImage extends StatelessWidget {
  final EventItem event;

  const EventBannerImage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      event.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: event.gradientColors,
            ),
          ),
          child: Center(
            child: Icon(
              event.icon,
              size: 42,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        );
      },
    );
  }
}
