import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/widget/event_banner_image.dart';
import 'package:flutter/material.dart';

/// Compact vertical card used inside the "Events Near Me" horizontal carousel.
class NearbyEventCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;

  const NearbyEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 240,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top image area with distance & price badges
              SizedBox(
                height: 115,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    EventBannerImage(event: event),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me,
                              size: 12,
                              color: Colors.tealAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.distance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.price,
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom text details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.category.toUpperCase(),
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.date} • ${event.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

