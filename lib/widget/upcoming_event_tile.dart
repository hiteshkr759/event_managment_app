import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/widget/event_banner_image.dart';
import 'package:flutter/material.dart';

/// Horizontal list item card for displaying an event in a vertical list.
class UpcomingEventTile extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;

  const UpcomingEventTile({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: EventBannerImage(event: event),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            event.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          event.price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.date} • ${event.time}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${event.location} (${event.distance})',
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

