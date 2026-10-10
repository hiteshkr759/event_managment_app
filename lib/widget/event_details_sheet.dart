import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/widget/event_banner_image.dart';
import 'package:flutter/material.dart';

/// Helper function to open the Event Details modal bottom sheet from any screen.
void showEventDetailsSheet(BuildContext context, EventItem event) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => EventDetailsSheet(event: event),
  );
}

/// Reusable bottom sheet content displaying full details for an [EventItem].
class EventDetailsSheet extends StatelessWidget {
  final EventItem event;

  const EventDetailsSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: EventBannerImage(event: event),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event.category,
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.near_me_outlined, size: 15, color: scheme.secondary),
              const SizedBox(width: 4),
              Text(
                event.distance,
                style: TextStyle(
                  color: scheme.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                event.price,
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${event.date} • ${event.time}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.location,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${event.attendees}+ attending',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registered for "${event.title}"!')),
                );
              },
              icon: const Icon(Icons.confirmation_number_outlined),
              label: const Text('Book / Register Now'),
            ),
          ),
        ],
      ),
    );
  }
}

