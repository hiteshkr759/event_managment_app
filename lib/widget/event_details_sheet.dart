import 'package:event_managment_app/models/event_model.dart';
import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/widget/attendees_list_sheet.dart';
import 'package:event_managment_app/widget/event_banner_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Opens the modal bottom sheet displaying full details and RSVP controls for [event].
///
/// **Purpose:**
/// Provides a single reusable helper function that any event card or list tile
/// can call when tapped.
///
/// **How it works:**
/// Calls Flutter's built-in [showModalBottomSheet] and passes `event.id` into
/// [EventDetailsSheet] so the sheet can watch live updates from [EventsProvider].
void showEventDetailsSheet(BuildContext context, EventItem event) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => EventDetailsSheet(eventId: event.id),
  );
}

/// Reusable bottom sheet content displaying full details for an [EventItem].
///
/// **Purpose:**
/// Shows the event banner, category/mode badges, price, date/time, venue or
/// online meeting link, attendee count, description, and the "Book / Attend"
/// toggle button.
///
/// **How it works:**
/// Looks up the latest [EventItem] from [EventsProvider] by [eventId] using
/// `context.watch<EventsProvider>()`. When the user taps "Book / Attend Event",
/// it calls [EventsProvider.toggleAttendance], which updates the attendee count
/// immediately and syncs with Supabase.
class EventDetailsSheet extends StatelessWidget {
  /// The unique ID of the event to display.
  final String eventId;

  /// Creates an [EventDetailsSheet] for the given [eventId].
  const EventDetailsSheet({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eventsProvider = context.watch<EventsProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    final event = eventsProvider.getEventById(eventId);
    if (event == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final currentUserId =
        profile?.id ??
        Supabase.instance.client.auth.currentUser?.id ??
        'guest-user';
    final isAttending = event.isUserAttending(currentUserId);
    final isOnline = event.isOnline;

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.indigo.withValues(alpha: 0.12)
                      : Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline
                          ? Icons.videocam_outlined
                          : Icons.location_on_outlined,
                      size: 14,
                      color: isOnline ? Colors.indigo : Colors.teal.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Online Event' : 'Offline Event',
                      style: TextStyle(
                        color: isOnline ? Colors.indigo : Colors.teal.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
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
                isOnline
                    ? Icons.laptop_chromebook_outlined
                    : Icons.location_on_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isOnline
                      ? '${event.onlinePlatform ?? 'Online Platform'} • ${event.meetingUrl ?? 'Link provided upon registration'}'
                      : '${event.location} (${event.distance})',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.groups_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.attendees} People Attending',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        isAttending
                            ? 'You are on the attendee list!'
                            : 'Tap "View Users" to see who is going',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showAttendeesListSheet(context, event),
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: const Text('View Users'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isAttending
                ? OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<EventsProvider>().toggleAttendance(
                        event,
                        profile,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cancelled registration for "${event.title}".',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Attending ✓ (Tap to Cancel)'),
                  )
                : FilledButton.icon(
                    onPressed: () async {
                      await context.read<EventsProvider>().toggleAttendance(
                        event,
                        profile,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'You are now attending "${event.title}"!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.confirmation_number_outlined),
                    label: const Text('Book / Attend Event'),
                  ),
          ),
        ],
      ),
    );
  }
}
