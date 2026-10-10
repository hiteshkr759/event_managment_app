import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/notifiers/profile_notifer.dart';
import 'package:event_managment_app/widget/event_banner_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper function to open the Event Details modal bottom sheet from any screen.
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

/// Opens a modal bottom sheet listing the people attending [event].
void showAttendeesListSheet(BuildContext context, EventItem event) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => AttendeesListSheet(event: event),
  );
}

/// Reusable bottom sheet content displaying full details for an [EventItem],
/// including Online/Offline details, live attendee count, and "View Attendees".
class EventDetailsSheet extends StatelessWidget {
  final String eventId;

  const EventDetailsSheet({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<List<EventItem>>(
      valueListenable: allEventsListNotifier,
      builder: (context, allEvents, _) {
        final event = allEvents.firstWhere(
          (item) => item.id == eventId,
          orElse: () => allEvents.first,
        );

        final currentUserId =
            profileNotifier.value?.id ??
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
                          color: isOnline
                              ? Colors.indigo
                              : Colors.teal.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online Event' : 'Offline Event',
                          style: TextStyle(
                            color: isOnline
                                ? Colors.indigo
                                : Colors.teal.shade700,
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
              // Interactive Attendee Count & "View Attendees" Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: isAttending
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          await toggleEventRegistration(event);
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
                          await toggleEventRegistration(event);
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
      },
    );
  }
}

/// Modal bottom sheet displaying the list of attendees for an event.
class AttendeesListSheet extends StatelessWidget {
  final EventItem event;

  const AttendeesListSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAdmin = profileNotifier.value?.isAdmin ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendees (${event.attendees})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Admin View (Emails Visible)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: event.attendeeList.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final attendee = event.attendeeList[index];
                final initial = attendee.name.isNotEmpty
                    ? attendee.name[0].toUpperCase()
                    : '?';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage: attendee.avatarUrl != null
                        ? NetworkImage(attendee.avatarUrl!)
                        : null,
                    child: attendee.avatarUrl == null
                        ? Text(
                            initial,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    attendee.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isAdmin
                        ? '${attendee.email} • ${attendee.registeredAtLabel}'
                        : attendee.registeredAtLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.verified_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                );
              },
            ),
          ),
          if (event.attendees > event.attendeeList.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '+ ${event.attendees - event.attendeeList.length} more registered attendees',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
